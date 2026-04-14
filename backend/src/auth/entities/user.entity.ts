import { Branch } from '../../branches/entities/branch.entity';
import {
  Column,
  CreateDateColumn,
  Entity,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
} from 'typeorm';

export enum UserRole {
  ADMIN = 'admin',
  CASHIER = 'cashier',
  MANAGER = 'manager',
}

@Entity('users')
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  username: string;

  @Column()
  password_hash: string;

  @Column()
  full_name: string;

  @Column({ type: 'enum', enum: UserRole, default: UserRole.CASHIER })
  role: UserRole;

  @Column('uuid', { nullable: true })
  branch_id: string;

  @ManyToOne(() => Branch, (branch) => branch.users, {
    nullable: true,
    onDelete: 'SET NULL',
  })
  @JoinColumn({ name: 'branch_id' })
  branch: Branch | null;

  @Column({ default: true })
  is_active: boolean;

  @CreateDateColumn()
  created_at: Date;
}
