export interface CfdCartStateItem {
  product_id: string;
  name: string;
  qty: number;
  unit_price: number;
  subtotal: number;
}

export interface CfdCartStatePayload {
  type: 'cart_state';
  branch_id: string;
  items: CfdCartStateItem[];
  total_amount: number;
  discount_amount: number;
  vat_amount: number;
  net_amount: number;
  updated_at: string;
  order_id?: string;
  order_no?: string;
  payment_status?: string;
}
