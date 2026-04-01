import {
  Column,
  Entity,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
} from 'typeorm';
import { Product } from '../../products/entities/product.entity';
import { Ingredient } from './ingredient.entity';

@Entity('recipes')
export class Recipe {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column('uuid')
  product_id: string;

  @Column('uuid')
  ingredient_id: string;

  @Column('decimal', { precision: 10, scale: 3 })
  usage_qty: number;

  @ManyToOne(() => Product, (product) => product.recipes)
  @JoinColumn({ name: 'product_id' })
  product: Product;

  @ManyToOne(() => Ingredient, (ingredient) => ingredient.recipes)
  @JoinColumn({ name: 'ingredient_id' })
  ingredient: Ingredient;
}
