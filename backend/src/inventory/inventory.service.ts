import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CreateIngredientDto } from './dto/create-ingredient.dto';
import { CreateRecipeDto } from './dto/create-recipe.dto';
import { Ingredient } from './entities/ingredient.entity';
import { Recipe } from './entities/recipe.entity';

@Injectable()
export class InventoryService {
  constructor(
    @InjectRepository(Ingredient)
    private ingredientsRepository: Repository<Ingredient>,
    @InjectRepository(Recipe)
    private recipesRepository: Repository<Recipe>,
  ) {}

  createIngredient(dto: CreateIngredientDto) {
    const ingredient = this.ingredientsRepository.create(dto);
    return this.ingredientsRepository.save(ingredient);
  }

  findAllIngredients() {
    return this.ingredientsRepository.find();
  }

  async findOneIngredient(id: string) {
    const ingredient = await this.ingredientsRepository.findOne({
      where: { id },
    });
    if (!ingredient) throw new NotFoundException(`Ingredient ${id} not found`);
    return ingredient;
  }

  findLowStock() {
    return this.ingredientsRepository
      .createQueryBuilder('i')
      .where('i.stock_qty <= i.min_alert_qty')
      .getMany();
  }

  createRecipe(dto: CreateRecipeDto) {
    const recipe = this.recipesRepository.create(dto);
    return this.recipesRepository.save(recipe);
  }

  findRecipesByProduct(productId: string) {
    return this.recipesRepository.find({
      where: { product_id: productId },
      relations: ['ingredient'],
    });
  }

  async deductStock(productId: string, qty: number) {
    const recipes = await this.recipesRepository.find({
      where: { product_id: productId },
      relations: ['ingredient'],
    });

    for (const recipe of recipes) {
      const deduction = recipe.usage_qty * qty;
      await this.ingredientsRepository
        .createQueryBuilder()
        .update(Ingredient)
        .set({ stock_qty: () => `stock_qty - ${deduction}` })
        .where('id = :id', { id: recipe.ingredient_id })
        .execute();
    }
  }
}
