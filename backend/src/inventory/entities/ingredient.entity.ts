import { Column, Entity, OneToMany, PrimaryGeneratedColumn } from 'typeorm';
import { Recipe } from './recipe.entity';

@Entity('ingredients')
export class Ingredient {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  name: string;

  @Column()
  unit: string;

  @Column('decimal', { precision: 10, scale: 3 })
  stock_qty: number;

  @Column('decimal', { precision: 10, scale: 3 })
  min_alert_qty: number;

  @OneToMany(() => Recipe, (recipe) => recipe.ingredient)
  recipes: Recipe[];
}
