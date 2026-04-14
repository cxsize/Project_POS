import { User } from '../../auth/entities/user.entity';
import { Order } from '../../orders/entities/order.entity';
import {
  Column,
  CreateDateColumn,
  Entity,
  OneToMany,
  PrimaryGeneratedColumn,
} from 'typeorm';

@Entity('branches')
export class Branch {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  name: string;

  @Column({ nullable: true })
  address: string | null;

  @Column({ default: true })
  is_active: boolean;

  @CreateDateColumn()
  created_at: Date;

  @OneToMany(() => User, (user) => user.branch)
  users: User[];

  @OneToMany(() => Order, (order) => order.branch)
  orders: Order[];
}
