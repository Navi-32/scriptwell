package com.scriptwell.model;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class Order {
    private int id;
    private Date orderDate;
    private double subtotal;
    private double shippingCharge;
    private double total;
    private String status;
    private String shippingAddress;
    private String paymentMethod;
    private String paymentRef;
    private String customerName;
    private String customerEmail;
    private String customerPhone;
    private int itemCount;
    private String firstCover;
    private List<CartItem> items = new ArrayList<>();

    public boolean isCancellable() { return "PLACED".equals(status); }

    /** Bootstrap colour used for the status badge. */
    public String getStatusColor() {
        if (status == null) return "secondary";
        switch (status) {
            case "PLACED": return "warning";
            case "SHIPPED": return "info";
            case "DELIVERED": return "success";
            default: return "danger";
        }
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public Date getOrderDate() { return orderDate; }
    public void setOrderDate(Date orderDate) { this.orderDate = orderDate; }
    public double getSubtotal() { return subtotal; }
    public void setSubtotal(double subtotal) { this.subtotal = subtotal; }
    public double getShippingCharge() { return shippingCharge; }
    public void setShippingCharge(double shippingCharge) { this.shippingCharge = shippingCharge; }
    public double getTotal() { return total; }
    public void setTotal(double total) { this.total = total; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getShippingAddress() { return shippingAddress; }
    public void setShippingAddress(String shippingAddress) { this.shippingAddress = shippingAddress; }
    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }
    public String getPaymentRef() { return paymentRef; }
    public void setPaymentRef(String paymentRef) { this.paymentRef = paymentRef; }
    public String getCustomerName() { return customerName; }
    public void setCustomerName(String customerName) { this.customerName = customerName; }
    public String getCustomerEmail() { return customerEmail; }
    public void setCustomerEmail(String customerEmail) { this.customerEmail = customerEmail; }
    public String getCustomerPhone() { return customerPhone; }
    public void setCustomerPhone(String customerPhone) { this.customerPhone = customerPhone; }
    public int getItemCount() { return itemCount; }
    public void setItemCount(int itemCount) { this.itemCount = itemCount; }
    public String getFirstCover() { return firstCover; }
    public void setFirstCover(String firstCover) { this.firstCover = firstCover; }
    public List<CartItem> getItems() { return items; }
    public void setItems(List<CartItem> items) { this.items = items; }
}
