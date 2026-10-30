-- =====================================================================
--  ScriptWell : 03_packages.sql
--  Business logic packages called from Java through CallableStatement
--
--  Application error codes (raised with RAISE_APPLICATION_ERROR)
--    -20001  email already registered       -20006  invalid quantity
--    -20002  invalid login                  -20007  order cannot be cancelled
--    -20003  insufficient stock             -20008  order not found
--    -20004  cart is empty                  -20009  invalid status
--    -20005  book not found                 -20010  validation failed
-- =====================================================================

-- ---------------------------------------------------------------------
-- PKG_USER : registration, login and user listing
-- ---------------------------------------------------------------------
CREATE OR REPLACE PACKAGE pkg_user AS
  FUNCTION  hash_password (p_email IN VARCHAR2, p_password IN VARCHAR2) RETURN VARCHAR2;

  PROCEDURE register_user (p_full_name IN VARCHAR2, p_email   IN VARCHAR2,
                           p_password  IN VARCHAR2, p_phone   IN VARCHAR2,
                           p_address   IN VARCHAR2, p_user_id OUT NUMBER);

  PROCEDURE login_user    (p_email IN VARCHAR2, p_password IN VARCHAR2,
                           p_user  OUT SYS_REFCURSOR);

  PROCEDURE get_all_users (p_result OUT SYS_REFCURSOR);
END pkg_user;
/

CREATE OR REPLACE PACKAGE BODY pkg_user AS

  FUNCTION hash_password (p_email IN VARCHAR2, p_password IN VARCHAR2) RETURN VARCHAR2 IS
    v_hash users.password_hash%TYPE;
  BEGIN
    -- SHA-256 of "email:password" so equal passwords never share a hash
    SELECT LOWER(RAWTOHEX(STANDARD_HASH(LOWER(TRIM(p_email)) || ':' || p_password, 'SHA256')))
      INTO v_hash FROM dual;
    RETURN v_hash;
  END hash_password;

  PROCEDURE register_user (p_full_name IN VARCHAR2, p_email   IN VARCHAR2,
                           p_password  IN VARCHAR2, p_phone   IN VARCHAR2,
                           p_address   IN VARCHAR2, p_user_id OUT NUMBER) IS
    v_count NUMBER;
  BEGIN
    IF TRIM(p_full_name) IS NULL OR TRIM(p_email) IS NULL THEN
      RAISE_APPLICATION_ERROR(-20010, 'Name and email are required');
    END IF;
    IF p_password IS NULL OR LENGTH(p_password) < 6 THEN
      RAISE_APPLICATION_ERROR(-20010, 'Password must be at least 6 characters');
    END IF;

    SELECT COUNT(*) INTO v_count FROM users WHERE email = LOWER(TRIM(p_email));
    IF v_count > 0 THEN
      RAISE_APPLICATION_ERROR(-20001, 'An account with this email already exists');
    END IF;

    INSERT INTO users (full_name, email, password_hash, phone, address)
    VALUES (TRIM(p_full_name), p_email, hash_password(p_email, p_password), p_phone, p_address)
    RETURNING user_id INTO p_user_id;
    COMMIT;
  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(-20001, 'An account with this email already exists');
  END register_user;

  PROCEDURE login_user (p_email IN VARCHAR2, p_password IN VARCHAR2,
                        p_user  OUT SYS_REFCURSOR) IS
    v_id users.user_id%TYPE;
  BEGIN
    SELECT user_id INTO v_id
      FROM users
     WHERE email = LOWER(TRIM(p_email))
       AND password_hash = hash_password(p_email, p_password);

    OPEN p_user FOR
      SELECT user_id, full_name, email, phone, address, role, created_at
        FROM users WHERE user_id = v_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20002, 'Invalid email or password');
  END login_user;

  PROCEDURE get_all_users (p_result OUT SYS_REFCURSOR) IS
  BEGIN
    OPEN p_result FOR
      SELECT u.user_id, u.full_name, u.email, u.phone, u.address, u.role, u.created_at,
             (SELECT COUNT(*) FROM orders o WHERE o.user_id = u.user_id) AS order_count,
             (SELECT NVL(SUM(total_amount),0) FROM orders o
               WHERE o.user_id = u.user_id AND o.status <> 'CANCELLED') AS total_spent
        FROM users u
       ORDER BY u.created_at DESC, u.user_id DESC;
  END get_all_users;

END pkg_user;
/

-- ---------------------------------------------------------------------
-- PKG_BOOK : catalogue queries and admin CRUD
-- ---------------------------------------------------------------------
CREATE OR REPLACE PACKAGE pkg_book AS
  PROCEDURE search_books   (p_keyword IN VARCHAR2, p_category_id IN NUMBER,
                            p_min_price IN NUMBER, p_max_price IN NUMBER,
                            p_sort IN VARCHAR2,   p_result OUT SYS_REFCURSOR);
  PROCEDURE get_book       (p_book_id IN NUMBER, p_result OUT SYS_REFCURSOR);
  PROCEDURE get_featured   (p_limit IN NUMBER,   p_result OUT SYS_REFCURSOR);
  PROCEDURE get_new_arrivals (p_limit IN NUMBER, p_result OUT SYS_REFCURSOR);
  PROCEDURE get_related    (p_book_id IN NUMBER, p_result OUT SYS_REFCURSOR);
  PROCEDURE get_categories (p_result OUT SYS_REFCURSOR);

  PROCEDURE add_book    (p_title IN VARCHAR2, p_author IN VARCHAR2, p_isbn IN VARCHAR2,
                         p_category_id IN NUMBER, p_price IN NUMBER, p_stock IN NUMBER,
                         p_description IN VARCHAR2, p_cover IN VARCHAR2, p_publisher IN VARCHAR2,
                         p_pub_year IN NUMBER, p_pages IN NUMBER, p_rating IN NUMBER,
                         p_book_id OUT NUMBER);
  PROCEDURE update_book (p_book_id IN NUMBER, p_title IN VARCHAR2, p_author IN VARCHAR2,
                         p_isbn IN VARCHAR2, p_category_id IN NUMBER, p_price IN NUMBER,
                         p_stock IN NUMBER, p_description IN VARCHAR2, p_cover IN VARCHAR2,
                         p_publisher IN VARCHAR2, p_pub_year IN NUMBER, p_pages IN NUMBER,
                         p_rating IN NUMBER, p_is_active IN CHAR);
  PROCEDURE delete_book (p_book_id IN NUMBER, p_outcome OUT VARCHAR2);
  PROCEDURE adjust_stock (p_book_id IN NUMBER, p_change IN NUMBER);

  PROCEDURE get_all_books_admin (p_result OUT SYS_REFCURSOR);
  PROCEDURE get_low_stock       (p_threshold IN NUMBER, p_result OUT SYS_REFCURSOR);
  PROCEDURE get_inventory_log   (p_limit IN NUMBER, p_result OUT SYS_REFCURSOR);
END pkg_book;
/

CREATE OR REPLACE PACKAGE BODY pkg_book AS

  PROCEDURE search_books (p_keyword IN VARCHAR2, p_category_id IN NUMBER,
                          p_min_price IN NUMBER, p_max_price IN NUMBER,
                          p_sort IN VARCHAR2,   p_result OUT SYS_REFCURSOR) IS
    v_kw VARCHAR2(210) := '%' || UPPER(TRIM(p_keyword)) || '%';
  BEGIN
    OPEN p_result FOR
      SELECT * FROM v_book_catalog
       WHERE is_active = 'Y'
         AND (p_keyword IS NULL
              OR UPPER(title) LIKE v_kw OR UPPER(author) LIKE v_kw
              OR UPPER(isbn) LIKE v_kw  OR UPPER(category_name) LIKE v_kw)
         AND (p_category_id IS NULL OR category_id = p_category_id)
         AND (p_min_price  IS NULL OR price >= p_min_price)
         AND (p_max_price  IS NULL OR price <= p_max_price)
       ORDER BY CASE WHEN p_sort = 'price_asc'  THEN price  END ASC,
                CASE WHEN p_sort = 'price_desc' THEN price  END DESC,
                CASE WHEN p_sort = 'rating'     THEN rating END DESC,
                CASE WHEN p_sort = 'newest'     THEN pub_year END DESC,
                title;
  END search_books;

  PROCEDURE get_book (p_book_id IN NUMBER, p_result OUT SYS_REFCURSOR) IS
  BEGIN
    OPEN p_result FOR SELECT * FROM v_book_catalog WHERE book_id = p_book_id;
  END get_book;

  PROCEDURE get_featured (p_limit IN NUMBER, p_result OUT SYS_REFCURSOR) IS
  BEGIN
    OPEN p_result FOR
      SELECT * FROM v_book_catalog WHERE is_active = 'Y'
       ORDER BY rating DESC, title FETCH FIRST p_limit ROWS ONLY;
  END get_featured;

  PROCEDURE get_new_arrivals (p_limit IN NUMBER, p_result OUT SYS_REFCURSOR) IS
  BEGIN
    OPEN p_result FOR
      SELECT * FROM v_book_catalog WHERE is_active = 'Y'
       ORDER BY pub_year DESC, book_id DESC FETCH FIRST p_limit ROWS ONLY;
  END get_new_arrivals;

  PROCEDURE get_related (p_book_id IN NUMBER, p_result OUT SYS_REFCURSOR) IS
  BEGIN
    OPEN p_result FOR
      SELECT * FROM v_book_catalog
       WHERE is_active = 'Y' AND book_id <> p_book_id
         AND category_id = (SELECT category_id FROM books WHERE book_id = p_book_id)
       ORDER BY rating DESC FETCH FIRST 4 ROWS ONLY;
  END get_related;

  PROCEDURE get_categories (p_result OUT SYS_REFCURSOR) IS
  BEGIN
    OPEN p_result FOR
      SELECT c.category_id, c.name, c.description, c.icon,
             (SELECT COUNT(*) FROM books b
               WHERE b.category_id = c.category_id AND b.is_active = 'Y') AS book_count
        FROM categories c
       ORDER BY c.name;
  END get_categories;

  PROCEDURE validate_book (p_title IN VARCHAR2, p_author IN VARCHAR2,
                           p_price IN NUMBER,   p_stock  IN NUMBER) IS
  BEGIN
    IF TRIM(p_title) IS NULL OR TRIM(p_author) IS NULL THEN
      RAISE_APPLICATION_ERROR(-20010, 'Title and author are required');
    ELSIF p_price IS NULL OR p_price <= 0 THEN
      RAISE_APPLICATION_ERROR(-20010, 'Price must be greater than zero');
    ELSIF p_stock IS NULL OR p_stock < 0 THEN
      RAISE_APPLICATION_ERROR(-20010, 'Stock cannot be negative');
    END IF;
  END validate_book;

  PROCEDURE add_book (p_title IN VARCHAR2, p_author IN VARCHAR2, p_isbn IN VARCHAR2,
                      p_category_id IN NUMBER, p_price IN NUMBER, p_stock IN NUMBER,
                      p_description IN VARCHAR2, p_cover IN VARCHAR2, p_publisher IN VARCHAR2,
                      p_pub_year IN NUMBER, p_pages IN NUMBER, p_rating IN NUMBER,
                      p_book_id OUT NUMBER) IS
  BEGIN
    validate_book(p_title, p_author, p_price, p_stock);
    INSERT INTO books (title, author, isbn, category_id, price, stock, description,
                       cover_image, publisher, pub_year, pages, rating)
    VALUES (p_title, p_author, p_isbn, p_category_id, p_price, p_stock, p_description,
            NVL(p_cover, 'default.svg'), p_publisher, p_pub_year, p_pages, NVL(p_rating, 4.0))
    RETURNING book_id INTO p_book_id;
    COMMIT;
  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(-20010, 'A book with this ISBN already exists');
  END add_book;

  PROCEDURE update_book (p_book_id IN NUMBER, p_title IN VARCHAR2, p_author IN VARCHAR2,
                         p_isbn IN VARCHAR2, p_category_id IN NUMBER, p_price IN NUMBER,
                         p_stock IN NUMBER, p_description IN VARCHAR2, p_cover IN VARCHAR2,
                         p_publisher IN VARCHAR2, p_pub_year IN NUMBER, p_pages IN NUMBER,
                         p_rating IN NUMBER, p_is_active IN CHAR) IS
  BEGIN
    validate_book(p_title, p_author, p_price, p_stock);
    UPDATE books
       SET title = p_title, author = p_author, isbn = p_isbn, category_id = p_category_id,
           price = p_price, stock = p_stock, description = p_description,
           cover_image = NVL(p_cover, cover_image), publisher = p_publisher,
           pub_year = p_pub_year, pages = p_pages, rating = NVL(p_rating, rating),
           is_active = NVL(p_is_active, is_active)
     WHERE book_id = p_book_id;

    IF SQL%ROWCOUNT = 0 THEN
      RAISE_APPLICATION_ERROR(-20005, 'Book not found');
    END IF;
    COMMIT;
  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(-20010, 'A book with this ISBN already exists');
  END update_book;

  -- Books that appear in past orders are only deactivated, never removed
  PROCEDURE delete_book (p_book_id IN NUMBER, p_outcome OUT VARCHAR2) IS
    v_sold NUMBER;
  BEGIN
    SELECT COUNT(*) INTO v_sold FROM order_items WHERE book_id = p_book_id;
    IF v_sold > 0 THEN
      UPDATE books SET is_active = 'N' WHERE book_id = p_book_id;
      p_outcome := 'DEACTIVATED';
    ELSE
      DELETE FROM books WHERE book_id = p_book_id;
      p_outcome := 'DELETED';
    END IF;
    IF SQL%ROWCOUNT = 0 THEN
      RAISE_APPLICATION_ERROR(-20005, 'Book not found');
    END IF;
    COMMIT;
  END delete_book;

  PROCEDURE adjust_stock (p_book_id IN NUMBER, p_change IN NUMBER) IS
    v_stock books.stock%TYPE;
  BEGIN
    SELECT stock INTO v_stock FROM books WHERE book_id = p_book_id FOR UPDATE;
    IF v_stock + p_change < 0 THEN
      RAISE_APPLICATION_ERROR(-20006, 'Stock cannot go below zero (current: ' || v_stock || ')');
    END IF;
    UPDATE books SET stock = stock + p_change WHERE book_id = p_book_id;
    COMMIT;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20005, 'Book not found');
  END adjust_stock;

  PROCEDURE get_all_books_admin (p_result OUT SYS_REFCURSOR) IS
  BEGIN
    OPEN p_result FOR SELECT * FROM v_book_catalog ORDER BY book_id;
  END get_all_books_admin;

  PROCEDURE get_low_stock (p_threshold IN NUMBER, p_result OUT SYS_REFCURSOR) IS
  BEGIN
    OPEN p_result FOR
      SELECT * FROM v_book_catalog
       WHERE is_active = 'Y' AND stock <= p_threshold
       ORDER BY stock, title;
  END get_low_stock;

  PROCEDURE get_inventory_log (p_limit IN NUMBER, p_result OUT SYS_REFCURSOR) IS
  BEGIN
    OPEN p_result FOR
      SELECT l.log_id, l.book_id, b.title, l.old_stock, l.new_stock, l.change_qty,
             l.reason, l.changed_at
        FROM inventory_log l JOIN books b ON b.book_id = l.book_id
       ORDER BY l.log_id DESC
       FETCH FIRST p_limit ROWS ONLY;
  END get_inventory_log;

END pkg_book;
/

-- ---------------------------------------------------------------------
-- PKG_CART : shopping cart management
-- ---------------------------------------------------------------------
CREATE OR REPLACE PACKAGE pkg_cart AS
  PROCEDURE add_item    (p_user_id IN NUMBER, p_book_id IN NUMBER, p_qty IN NUMBER);
  PROCEDURE update_item (p_user_id IN NUMBER, p_book_id IN NUMBER, p_qty IN NUMBER);
  PROCEDURE remove_item (p_user_id IN NUMBER, p_book_id IN NUMBER);
  PROCEDURE clear_cart  (p_user_id IN NUMBER);
  PROCEDURE get_cart    (p_user_id IN NUMBER, p_result OUT SYS_REFCURSOR);
  FUNCTION  cart_total  (p_user_id IN NUMBER) RETURN NUMBER;
  FUNCTION  cart_count  (p_user_id IN NUMBER) RETURN NUMBER;
END pkg_cart;
/

CREATE OR REPLACE PACKAGE BODY pkg_cart AS

  PROCEDURE check_stock (p_book_id IN NUMBER, p_qty IN NUMBER) IS
    v_title books.title%TYPE;
    v_stock books.stock%TYPE;
  BEGIN
    IF p_qty IS NULL OR p_qty < 1 OR p_qty > 99 THEN
      RAISE_APPLICATION_ERROR(-20006, 'Quantity must be between 1 and 99');
    END IF;
    IF fn_is_in_stock(p_book_id, p_qty) = 'N' THEN
      BEGIN
        SELECT title, stock INTO v_title, v_stock FROM books WHERE book_id = p_book_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RAISE_APPLICATION_ERROR(-20005, 'Book not found');
      END;
      RAISE_APPLICATION_ERROR(-20003,
        'Only ' || v_stock || ' cop' || CASE WHEN v_stock = 1 THEN 'y' ELSE 'ies' END
        || ' of "' || v_title || '" available');
    END IF;
  END check_stock;

  PROCEDURE add_item (p_user_id IN NUMBER, p_book_id IN NUMBER, p_qty IN NUMBER) IS
    v_existing NUMBER := 0;
  BEGIN
    BEGIN
      SELECT quantity INTO v_existing FROM cart_items
       WHERE user_id = p_user_id AND book_id = p_book_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN v_existing := 0;
    END;

    check_stock(p_book_id, v_existing + p_qty);

    MERGE INTO cart_items c
    USING (SELECT p_user_id AS user_id, p_book_id AS book_id FROM dual) s
       ON (c.user_id = s.user_id AND c.book_id = s.book_id)
     WHEN MATCHED THEN UPDATE SET c.quantity = c.quantity + p_qty, c.added_at = SYSDATE
     WHEN NOT MATCHED THEN INSERT (user_id, book_id, quantity) VALUES (p_user_id, p_book_id, p_qty);
    COMMIT;
  END add_item;

  PROCEDURE update_item (p_user_id IN NUMBER, p_book_id IN NUMBER, p_qty IN NUMBER) IS
  BEGIN
    IF p_qty <= 0 THEN
      remove_item(p_user_id, p_book_id);
      RETURN;
    END IF;
    check_stock(p_book_id, p_qty);
    UPDATE cart_items SET quantity = p_qty
     WHERE user_id = p_user_id AND book_id = p_book_id;
    COMMIT;
  END update_item;

  PROCEDURE remove_item (p_user_id IN NUMBER, p_book_id IN NUMBER) IS
  BEGIN
    DELETE FROM cart_items WHERE user_id = p_user_id AND book_id = p_book_id;
    COMMIT;
  END remove_item;

  PROCEDURE clear_cart (p_user_id IN NUMBER) IS
  BEGIN
    DELETE FROM cart_items WHERE user_id = p_user_id;
    COMMIT;
  END clear_cart;

  PROCEDURE get_cart (p_user_id IN NUMBER, p_result OUT SYS_REFCURSOR) IS
  BEGIN
    OPEN p_result FOR
      SELECT c.book_id, b.title, b.author, b.cover_image, b.price, b.stock,
             c.quantity, (b.price * c.quantity) AS line_total
        FROM cart_items c JOIN books b ON b.book_id = c.book_id
       WHERE c.user_id = p_user_id
       ORDER BY c.added_at, c.cart_id;
  END get_cart;

  FUNCTION cart_total (p_user_id IN NUMBER) RETURN NUMBER IS
    v_total NUMBER;
  BEGIN
    SELECT NVL(SUM(b.price * c.quantity), 0) INTO v_total
      FROM cart_items c JOIN books b ON b.book_id = c.book_id
     WHERE c.user_id = p_user_id;
    RETURN v_total;
  END cart_total;

  FUNCTION cart_count (p_user_id IN NUMBER) RETURN NUMBER IS
    v_count NUMBER;
  BEGIN
    SELECT NVL(SUM(quantity), 0) INTO v_count FROM cart_items WHERE user_id = p_user_id;
    RETURN v_count;
  END cart_count;

END pkg_cart;
/

-- ---------------------------------------------------------------------
-- PKG_ORDER : checkout, order history and order administration
-- ---------------------------------------------------------------------
CREATE OR REPLACE PACKAGE pkg_order AS
  e_empty_cart EXCEPTION;

  PROCEDURE place_order (p_user_id IN NUMBER, p_address IN VARCHAR2, p_payment IN VARCHAR2,
                         p_order_id OUT NUMBER, p_payment_ref OUT VARCHAR2);
  PROCEDURE buy_now     (p_user_id IN NUMBER, p_book_id IN NUMBER, p_qty IN NUMBER,
                         p_address IN VARCHAR2, p_payment IN VARCHAR2,
                         p_order_id OUT NUMBER, p_payment_ref OUT VARCHAR2);

  PROCEDURE get_user_orders (p_user_id IN NUMBER, p_result OUT SYS_REFCURSOR);
  PROCEDURE get_order       (p_order_id IN NUMBER, p_user_id IN NUMBER,
                             p_header OUT SYS_REFCURSOR, p_items OUT SYS_REFCURSOR);
  PROCEDURE get_all_orders  (p_status IN VARCHAR2, p_result OUT SYS_REFCURSOR);
  PROCEDURE update_status   (p_order_id IN NUMBER, p_status IN VARCHAR2);
  PROCEDURE cancel_order    (p_order_id IN NUMBER, p_user_id IN NUMBER);
  PROCEDURE sales_by_category (p_result OUT SYS_REFCURSOR);
END pkg_order;
/

CREATE OR REPLACE PACKAGE BODY pkg_order AS

  FUNCTION new_payment_ref (p_method IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN CASE p_method WHEN 'COD' THEN 'COD-' ELSE 'TXN-' END
           || TO_CHAR(SYSTIMESTAMP, 'YYMMDDHH24MISS')
           || TRUNC(DBMS_RANDOM.VALUE(100, 999));
  END new_payment_ref;

  PROCEDURE check_input (p_address IN VARCHAR2, p_payment IN VARCHAR2) IS
  BEGIN
    IF TRIM(p_address) IS NULL OR LENGTH(TRIM(p_address)) < 10 THEN
      RAISE_APPLICATION_ERROR(-20010, 'Please enter a complete shipping address');
    END IF;
    IF p_payment NOT IN ('CARD','UPI','COD') THEN
      RAISE_APPLICATION_ERROR(-20010, 'Unsupported payment method');
    END IF;
  END check_input;

  -- Converts the whole cart into an order inside one transaction.
  -- An explicit cursor locks the book rows so stock cannot be oversold.
  PROCEDURE place_order (p_user_id IN NUMBER, p_address IN VARCHAR2, p_payment IN VARCHAR2,
                         p_order_id OUT NUMBER, p_payment_ref OUT VARCHAR2) IS
    CURSOR c_cart IS
      SELECT c.book_id, c.quantity, b.price, b.stock, b.title
        FROM cart_items c JOIN books b ON b.book_id = c.book_id
       WHERE c.user_id = p_user_id
         FOR UPDATE OF b.stock;
    r_item     c_cart%ROWTYPE;
    v_subtotal NUMBER := 0;
    v_shipping NUMBER;
    v_items    NUMBER;
  BEGIN
    check_input(p_address, p_payment);

    SELECT COUNT(*) INTO v_items FROM cart_items WHERE user_id = p_user_id;
    IF v_items = 0 THEN
      RAISE e_empty_cart;
    END IF;

    v_subtotal := pkg_cart.cart_total(p_user_id);
    v_shipping := fn_shipping_charge(v_subtotal);
    p_payment_ref := new_payment_ref(p_payment);

    INSERT INTO orders (user_id, subtotal, shipping_charge, total_amount,
                        shipping_address, payment_method, payment_ref)
    VALUES (p_user_id, v_subtotal, v_shipping, v_subtotal + v_shipping,
            TRIM(p_address), p_payment, p_payment_ref)
    RETURNING order_id INTO p_order_id;

    OPEN c_cart;
    LOOP
      FETCH c_cart INTO r_item;
      EXIT WHEN c_cart%NOTFOUND;

      IF r_item.stock < r_item.quantity THEN
        RAISE_APPLICATION_ERROR(-20003, 'Only ' || r_item.stock || ' copies of "'
                                || r_item.title || '" left in stock');
      END IF;

      INSERT INTO order_items (order_id, book_id, quantity, unit_price)
      VALUES (p_order_id, r_item.book_id, r_item.quantity, r_item.price);

      UPDATE books SET stock = stock - r_item.quantity WHERE book_id = r_item.book_id;
    END LOOP;
    CLOSE c_cart;

    DELETE FROM cart_items WHERE user_id = p_user_id;
    COMMIT;
  EXCEPTION
    WHEN e_empty_cart THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(-20004, 'Your cart is empty');
    WHEN OTHERS THEN
      IF c_cart%ISOPEN THEN CLOSE c_cart; END IF;
      ROLLBACK;
      RAISE;
  END place_order;

  -- Single-book purchase that bypasses (and keeps) the cart
  PROCEDURE buy_now (p_user_id IN NUMBER, p_book_id IN NUMBER, p_qty IN NUMBER,
                     p_address IN VARCHAR2, p_payment IN VARCHAR2,
                     p_order_id OUT NUMBER, p_payment_ref OUT VARCHAR2) IS
    v_price    books.price%TYPE;
    v_stock    books.stock%TYPE;
    v_title    books.title%TYPE;
    v_subtotal NUMBER;
    v_shipping NUMBER;
  BEGIN
    check_input(p_address, p_payment);
    IF p_qty IS NULL OR p_qty < 1 OR p_qty > 99 THEN
      RAISE_APPLICATION_ERROR(-20006, 'Quantity must be between 1 and 99');
    END IF;

    SELECT price, stock, title INTO v_price, v_stock, v_title
      FROM books WHERE book_id = p_book_id AND is_active = 'Y'
       FOR UPDATE;

    IF v_stock < p_qty THEN
      RAISE_APPLICATION_ERROR(-20003, 'Only ' || v_stock || ' copies of "' || v_title || '" left in stock');
    END IF;

    v_subtotal := v_price * p_qty;
    v_shipping := fn_shipping_charge(v_subtotal);
    p_payment_ref := new_payment_ref(p_payment);

    INSERT INTO orders (user_id, subtotal, shipping_charge, total_amount,
                        shipping_address, payment_method, payment_ref)
    VALUES (p_user_id, v_subtotal, v_shipping, v_subtotal + v_shipping,
            TRIM(p_address), p_payment, p_payment_ref)
    RETURNING order_id INTO p_order_id;

    INSERT INTO order_items (order_id, book_id, quantity, unit_price)
    VALUES (p_order_id, p_book_id, p_qty, v_price);

    UPDATE books SET stock = stock - p_qty WHERE book_id = p_book_id;
    COMMIT;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(-20005, 'Book not found');
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END buy_now;

  PROCEDURE get_user_orders (p_user_id IN NUMBER, p_result OUT SYS_REFCURSOR) IS
  BEGIN
    OPEN p_result FOR
      SELECT o.order_id, o.order_date, o.total_amount, o.status, o.payment_method,
             o.payment_ref,
             (SELECT SUM(quantity) FROM order_items i WHERE i.order_id = o.order_id) AS item_count,
             (SELECT MIN(b.cover_image) KEEP (DENSE_RANK FIRST ORDER BY i.order_item_id)
                FROM order_items i JOIN books b ON b.book_id = i.book_id
               WHERE i.order_id = o.order_id) AS first_cover
        FROM orders o
       WHERE o.user_id = p_user_id
       ORDER BY o.order_date DESC, o.order_id DESC;
  END get_user_orders;

  -- p_user_id NULL means "admin view" (any order)
  PROCEDURE get_order (p_order_id IN NUMBER, p_user_id IN NUMBER,
                       p_header OUT SYS_REFCURSOR, p_items OUT SYS_REFCURSOR) IS
    v_owner orders.user_id%TYPE;
  BEGIN
    SELECT user_id INTO v_owner FROM orders WHERE order_id = p_order_id;
    IF p_user_id IS NOT NULL AND v_owner <> p_user_id THEN
      RAISE_APPLICATION_ERROR(-20008, 'Order not found');
    END IF;

    OPEN p_header FOR
      SELECT o.order_id, o.order_date, o.subtotal, o.shipping_charge, o.total_amount,
             o.status, o.shipping_address, o.payment_method, o.payment_ref,
             u.full_name, u.email, u.phone
        FROM orders o JOIN users u ON u.user_id = o.user_id
       WHERE o.order_id = p_order_id;

    OPEN p_items FOR
      SELECT i.book_id, b.title, b.author, b.cover_image, i.quantity, i.unit_price,
             (i.quantity * i.unit_price) AS line_total
        FROM order_items i JOIN books b ON b.book_id = i.book_id
       WHERE i.order_id = p_order_id
       ORDER BY i.order_item_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20008, 'Order not found');
  END get_order;

  PROCEDURE get_all_orders (p_status IN VARCHAR2, p_result OUT SYS_REFCURSOR) IS
  BEGIN
    OPEN p_result FOR
      SELECT o.order_id, o.order_date, o.total_amount, o.status, o.payment_method,
             o.payment_ref, u.full_name, u.email,
             (SELECT SUM(quantity) FROM order_items i WHERE i.order_id = o.order_id) AS item_count
        FROM orders o JOIN users u ON u.user_id = o.user_id
       WHERE p_status IS NULL OR o.status = p_status
       ORDER BY o.order_date DESC, o.order_id DESC;
  END get_all_orders;

  -- Restores stock for every line of a cancelled order using a cursor FOR loop
  PROCEDURE restock_order (p_order_id IN NUMBER) IS
    CURSOR c_lines IS SELECT book_id, quantity FROM order_items WHERE order_id = p_order_id;
  BEGIN
    FOR r IN c_lines LOOP
      UPDATE books SET stock = stock + r.quantity WHERE book_id = r.book_id;
    END LOOP;
  END restock_order;

  PROCEDURE update_status (p_order_id IN NUMBER, p_status IN VARCHAR2) IS
    v_current orders.status%TYPE;
  BEGIN
    IF p_status NOT IN ('PLACED','SHIPPED','DELIVERED','CANCELLED') THEN
      RAISE_APPLICATION_ERROR(-20009, 'Invalid order status');
    END IF;

    SELECT status INTO v_current FROM orders WHERE order_id = p_order_id FOR UPDATE;

    IF v_current = 'CANCELLED' AND p_status <> 'CANCELLED' THEN
      RAISE_APPLICATION_ERROR(-20009, 'A cancelled order cannot be reopened');
    END IF;
    IF v_current = p_status THEN
      RETURN;
    END IF;

    IF p_status = 'CANCELLED' THEN
      restock_order(p_order_id);
    END IF;

    UPDATE orders SET status = p_status WHERE order_id = p_order_id;
    COMMIT;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20008, 'Order not found');
  END update_status;

  PROCEDURE cancel_order (p_order_id IN NUMBER, p_user_id IN NUMBER) IS
    v_status orders.status%TYPE;
  BEGIN
    SELECT status INTO v_status FROM orders
     WHERE order_id = p_order_id AND user_id = p_user_id;
    IF v_status <> 'PLACED' THEN
      RAISE_APPLICATION_ERROR(-20007, 'Only orders that have not shipped can be cancelled');
    END IF;
    update_status(p_order_id, 'CANCELLED');
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20008, 'Order not found');
  END cancel_order;

  PROCEDURE sales_by_category (p_result OUT SYS_REFCURSOR) IS
  BEGIN
    OPEN p_result FOR
      SELECT c.name, NVL(SUM(i.quantity), 0) AS units, NVL(SUM(i.quantity * i.unit_price), 0) AS revenue
        FROM categories c
        LEFT JOIN books b       ON b.category_id = c.category_id
        LEFT JOIN order_items i ON i.book_id = b.book_id
        LEFT JOIN orders o      ON o.order_id = i.order_id
       WHERE o.order_id IS NULL OR o.status <> 'CANCELLED'
       GROUP BY c.name
       ORDER BY revenue DESC;
  END sales_by_category;

END pkg_order;
/
