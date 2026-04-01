import {
  Body,
  Controller,
  Get,
  Param,
  ParseUUIDPipe,
  Post,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CreateIngredientDto } from './dto/create-ingredient.dto';
import { CreateRecipeDto } from './dto/create-recipe.dto';
import { InventoryService } from './inventory.service';

@ApiTags('Inventory')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('inventory')
export class InventoryController {
  constructor(private inventoryService: InventoryService) {}

  @Post('ingredients')
  @ApiOperation({ summary: 'Create a new ingredient' })
  createIngredient(@Body() dto: CreateIngredientDto) {
    return this.inventoryService.createIngredient(dto);
  }

  @Get('ingredients')
  @ApiOperation({ summary: 'List all ingredients' })
  findAllIngredients() {
    return this.inventoryService.findAllIngredients();
  }

  @Get('ingredients/low-stock')
  @ApiOperation({ summary: 'List ingredients below minimum stock' })
  findLowStock() {
    return this.inventoryService.findLowStock();
  }

  @Get('ingredients/:id')
  @ApiOperation({ summary: 'Get ingredient by ID' })
  findOneIngredient(@Param('id', ParseUUIDPipe) id: string) {
    return this.inventoryService.findOneIngredient(id);
  }

  @Post('recipes')
  @ApiOperation({ summary: 'Create a recipe (BOM link)' })
  createRecipe(@Body() dto: CreateRecipeDto) {
    return this.inventoryService.createRecipe(dto);
  }

  @Get('recipes/product/:productId')
  @ApiOperation({ summary: 'Get BOM recipes for a product' })
  findRecipesByProduct(@Param('productId', ParseUUIDPipe) productId: string) {
    return this.inventoryService.findRecipesByProduct(productId);
  }
}
