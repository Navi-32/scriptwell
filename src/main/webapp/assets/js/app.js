// ScriptWell — small client-side helpers
(function () {
  const ctx = document.body.dataset.ctx || "";

  // Toast message in the bottom-right corner
  function toast(message, ok) {
    const el = document.createElement("div");
    el.className = "sw-toast alert shadow " + (ok ? "alert-success" : "alert-danger");
    el.innerHTML = '<i class="bi ' + (ok ? "bi-check-circle-fill" : "bi-exclamation-triangle-fill") + ' me-2"></i>';
    el.appendChild(document.createTextNode(message));
    document.body.appendChild(el);
    setTimeout(() => el.remove(), 3000);
  }

  // "Add to cart" buttons post with fetch so the shopper stays on the page
  document.addEventListener("submit", async (e) => {
    const form = e.target;
    if (!form.matches(".js-add-cart")) return;
    e.preventDefault();
    const res = await fetch(form.action, {
      method: "POST",
      headers: { "X-Requested-With": "fetch" },
      body: new URLSearchParams(new FormData(form)),
    });
    const data = await res.json().catch(() => ({ ok: false, message: "Something went wrong" }));
    if (data.login) {
      location.href = ctx + "/login?next=" + encodeURIComponent(location.pathname.replace(ctx, "") + location.search);
      return;
    }
    toast(data.message, data.ok);
    const badge = document.getElementById("cartBadge");
    if (badge && data.ok) {
      badge.textContent = data.count;
      badge.classList.toggle("d-none", data.count === 0);
    }
  });

  // +/- quantity steppers
  document.querySelectorAll("[data-qty-step]").forEach((btn) => {
    btn.addEventListener("click", () => {
      const input = btn.closest(".qty-group").querySelector("input");
      const max = parseInt(input.max || "99", 10);
      const next = Math.min(max, Math.max(1, (parseInt(input.value, 10) || 1) + parseInt(btn.dataset.qtyStep, 10)));
      input.value = next;
      input.dispatchEvent(new Event("change", { bubbles: true }));
    });
  });

  // Cart rows auto-submit when the quantity changes
  document.querySelectorAll(".js-auto-submit input").forEach((input) => {
    input.addEventListener("change", () => input.form.submit());
  });

  // Keep Buy Now quantity in sync with the visible quantity input
  const qtyInput = document.getElementById("qtyInput");
  if (qtyInput) {
    qtyInput.addEventListener("change", () => {
      document.querySelectorAll(".js-qty-mirror").forEach((h) => (h.value = qtyInput.value));
    });
  }

  // Checkout: show the fields for the chosen payment method
  const payRadios = document.querySelectorAll("input[name=payment]");
  function showPayFields() {
    const chosen = document.querySelector("input[name=payment]:checked");
    document.querySelectorAll("[data-pay]").forEach((box) => {
      const on = chosen && box.dataset.pay === chosen.value;
      box.classList.toggle("d-none", !on);
      box.querySelectorAll("input").forEach((i) => (i.required = on));
    });
  }
  payRadios.forEach((r) => r.addEventListener("change", showPayFields));
  if (payRadios.length) showPayFields();

  // Card number / expiry formatting
  const card = document.getElementById("cardNumber");
  if (card) {
    card.addEventListener("input", () => {
      card.value = card.value.replace(/\D/g, "").slice(0, 16).replace(/(\d{4})(?=\d)/g, "$1 ");
    });
  }
  const exp = document.getElementById("expiry");
  if (exp) {
    exp.addEventListener("input", () => {
      let v = exp.value.replace(/\D/g, "").slice(0, 4);
      if (v.length > 2) v = v.slice(0, 2) + "/" + v.slice(2);
      exp.value = v;
    });
  }

  // Simulated payment: show a short "processing" state before submitting
  const payForm = document.getElementById("checkoutForm");
  if (payForm) {
    payForm.addEventListener("submit", (e) => {
      if (!payForm.checkValidity()) {
        e.preventDefault();
        payForm.classList.add("was-validated");
        return;
      }
      if (payForm.dataset.sent) return;
      e.preventDefault();
      payForm.dataset.sent = "1";
      const btn = document.getElementById("payBtn");
      btn.disabled = true;
      btn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>Processing payment…';
      setTimeout(() => payForm.submit(), 1200);
    });
  }

  // Confirm dangerous admin/customer actions
  document.querySelectorAll("form[data-confirm]").forEach((f) => {
    f.addEventListener("submit", (e) => {
      if (!confirm(f.dataset.confirm)) e.preventDefault();
    });
  });

  // Register form: password match hint
  const pw = document.getElementById("password"), cf = document.getElementById("confirm");
  if (pw && cf) {
    const check = () => cf.setCustomValidity(cf.value && cf.value !== pw.value ? "Passwords do not match" : "");
    pw.addEventListener("input", check);
    cf.addEventListener("input", check);
  }
})();
