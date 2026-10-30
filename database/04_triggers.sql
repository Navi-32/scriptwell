-- =====================================================================
--  ScriptWell : 04_triggers.sql
-- =====================================================================

-- Normalise e-mail addresses so login is case-insensitive
CREATE OR REPLACE TRIGGER trg_users_normalize
BEFORE INSERT OR UPDATE OF email ON users
FOR EACH ROW
BEGIN
  :NEW.email := LOWER(TRIM(:NEW.email));
  IF INSTR(:NEW.email, '@') = 0 THEN
    RAISE_APPLICATION_ERROR(-20010, 'Invalid email address');
  END IF;
END;
/

-- Clean book data before it is stored
CREATE OR REPLACE TRIGGER trg_books_before_save
BEFORE INSERT OR UPDATE ON books
FOR EACH ROW
BEGIN
  :NEW.title  := TRIM(:NEW.title);
  :NEW.author := TRIM(:NEW.author);
  :NEW.isbn   := UPPER(TRIM(:NEW.isbn));
  IF :NEW.pub_year > EXTRACT(YEAR FROM SYSDATE) THEN
    RAISE_APPLICATION_ERROR(-20010, 'Publication year cannot be in the future');
  END IF;
END;
/

-- Every stock movement is written to INVENTORY_LOG automatically
CREATE OR REPLACE TRIGGER trg_books_stock_audit
AFTER INSERT OR UPDATE OF stock ON books
FOR EACH ROW
DECLARE
  v_reason inventory_log.reason%TYPE;
BEGIN
  IF INSERTING THEN
    v_reason := 'INITIAL STOCK';
  ELSIF :NEW.stock < :OLD.stock THEN
    v_reason := 'SALE / ADJUSTMENT';
  ELSE
    v_reason := 'RESTOCK / RETURN';
  END IF;

  IF INSERTING OR :NEW.stock <> :OLD.stock THEN
    INSERT INTO inventory_log (book_id, old_stock, new_stock, change_qty, reason)
    VALUES (:NEW.book_id, :OLD.stock, :NEW.stock, :NEW.stock - NVL(:OLD.stock, 0), v_reason);
  END IF;
END;
/

-- Order status history
CREATE OR REPLACE TRIGGER trg_orders_status_audit
AFTER INSERT OR UPDATE OF status ON orders
FOR EACH ROW
BEGIN
  INSERT INTO order_status_audit (order_id, old_status, new_status, changed_by)
  VALUES (:NEW.order_id, :OLD.status, :NEW.status, SYS_CONTEXT('USERENV', 'SESSION_USER'));
END;
/
