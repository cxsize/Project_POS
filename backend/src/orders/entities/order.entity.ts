import { Branch } from '../../branches/entities/branch.entity';
import {
  Column,
  CreateDateColumn,
  Entity,
  JoinColumn,
  ManyToOne,
  OneToMany,
  PrimaryGeneratedColumn,
} from 'typeorm';
import { OrderItem } from './order-item.entity';
import { Payment } from './payment.entity';

export enum PaymentStatus {
  PENDING = 'pending',
  PAID = 'paid',
  VOID = 'void',
}

@Entity('orders')
export class Order {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  order_no: string;

  @Column('uuid')
  branch_id: string;

  @ManyToOne(() => Branch, (branch) => branch.orders)
  @JoinColumn({ name: 'branch_id' })
  branch: Branch;

  @Column('uuid')
  staff_id: string;

  @Column('decimal', { precision: 10, scale: 2 })
  total_amount: number;

  @Column('decimal', { precision: 10, scale: 2, default: 0 })
  discount_amount: number;

  @Column('decimal', { precision: 10, scale: 2, default: 0 })
  vat_amount: number;

  @Column('decimal', { precision: 10, scale: 2 })
  net_amount: number;

  @Column({ type: 'enum', enum: PaymentStatus, default: PaymentStatus.PENDING })
  payment_status: PaymentStatus;

  @Column({ default: false })
  sync_status_acc: boolean;

  @CreateDateColumn()
  created_at: Date;

  @OneToMany(() => OrderItem, (item) => item.order)
  items: OrderItem[];

  @OneToMany(() => Payment, (payment) => payment.order)
  payments: Payment[];
}
