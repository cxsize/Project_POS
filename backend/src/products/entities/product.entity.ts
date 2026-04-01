import { Column, Entity, OneToMany, PrimaryGeneratedColumn } from 'typeorm';
import { Recipe } from '../../inventory/entities/recipe.entity';
import { OrderItem } from '../../orders/entities/order-item.entity';

@Entity('products')
export class Product {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  sku: string;

  @Column()
  name: string;

  @Column('decimal', { precision: 10, scale: 2 })
  base_price: number;

  @Column('uuid', { nullable: true })
  category_id: string;

  @Column({ default: true })
  is_active: boolean;

  @OneToMany(() => Recipe, (recipe) => recipe.product)
  recipes: Recipe[];

  @OneToMany(() => OrderItem, (item) => item.product)
  order_items: OrderItem[];
}
