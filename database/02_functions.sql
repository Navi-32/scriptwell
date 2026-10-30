-- =====================================================================
--  ScriptWell : 02_functions.sql
--  Stand-alone stored functions and procedures
-- =====================================================================

-- Shipping rule: free delivery for orders of Rs.499 and above, else Rs.49
CREATE OR REPLACE FUNCTION fn_shipping_charge (p_subtotal IN NUMBER)
RETURN NUMBER
IS
BEGIN
  IF p_subtotal IS NULL OR p_subtotal = 0 THEN
    RETURN 0;
  ELSIF p_subtotal >= 499 THEN
    RETURN 0;
  ELSE
    RETURN 49;
  END IF;
END fn_shipping_charge;
/

-- Returns 'Y' when the requested quantity of an active book is available
CREATE OR REPLACE FUNCTION fn_is_in_stock (p_book_id IN NUMBER, p_qty IN NUMBER)
RETURN VARCHAR2
IS
  v_stock books.stock%TYPE;
BEGIN
  SELECT stock INTO v_stock
    FROM books
   WHERE book_id = p_book_id AND is_active = 'Y';

  RETURN CASE WHEN v_stock >= p_qty THEN 'Y' ELSE 'N' END;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 'N';
END fn_is_in_stock;
/

-- Total revenue of all non-cancelled orders
CREATE OR REPLACE FUNCTION fn_total_revenue
RETURN NUMBER
IS
  v_total NUMBER;
BEGIN
  SELECT NVL(SUM(total_amount), 0) INTO v_total
    FROM orders
   WHERE status <> 'CANCELLED';
  RETURN v_total;
END fn_total_revenue;
/

-- Key figures for the admin dashboard, returned through OUT parameters
CREATE OR REPLACE PROCEDURE sp_get_dashboard_stats (
  p_total_books   OUT NUMBER,
  p_total_users   OUT NUMBER,
  p_total_orders  OUT NUMBER,
  p_revenue       OUT NUMBER,
  p_low_stock     OUT NUMBER,
  p_pending       OUT NUMBER
)
IS
BEGIN
  SELECT COUNT(*) INTO p_total_books  FROM books  WHERE is_active = 'Y';
  SELECT COUNT(*) INTO p_total_users  FROM users  WHERE role = 'CUSTOMER';
  SELECT COUNT(*) INTO p_total_orders FROM orders;
  SELECT COUNT(*) INTO p_low_stock    FROM books  WHERE is_active = 'Y' AND stock <= 5;
  SELECT COUNT(*) INTO p_pending      FROM orders WHERE status = 'PLACED';
  p_revenue := fn_total_revenue;
END sp_get_dashboard_stats;
/
