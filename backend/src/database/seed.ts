import * as bcrypt from 'bcrypt';
import { DataSource } from 'typeorm';
import { User, UserRole } from '../auth/entities/user.entity';
import { Ingredient } from '../inventory/entities/ingredient.entity';
import { Recipe } from '../inventory/entities/recipe.entity';
import { OrderItem } from '../orders/entities/order-item.entity';
import { Order } from '../orders/entities/order.entity';
import { Payment } from '../orders/entities/payment.entity';
import { Category } from '../products/entities/category.entity';
import { Product } from '../products/entities/product.entity';

async function seed() {
  const dataSource = new DataSource({
    type: 'postgres',
    host: process.env.DB_HOST || 'localhost',
    port: Number(process.env.DB_PORT) || 5432,
    username: process.env.DB_USERNAME || 'pos_user',
    password: process.env.DB_PASSWORD || 'pos_password',
    database: process.env.DB_DATABASE || 'pos_db',
    entities: [
      User,
      Category,
      Product,
      Ingredient,
      Recipe,
      Order,
      OrderItem,
      Payment,
    ],
    synchronize: true,
  });

  await dataSource.initialize();
  console.log('Database connected');

  // Seed Users
  const usersRepo = dataSource.getRepository(User);
  const existingAdmin = await usersRepo.findOne({
    where: { username: 'admin' },
  });
  if (!existingAdmin) {
    const passwordHash = await bcrypt.hash('admin123', 10);
    await usersRepo.save([
      {
        username: 'admin',
        password_hash: passwordHash,
        full_name: 'Admin User',
        role: UserRole.ADMIN,
      },
      {
        username: 'cashier1',
        password_hash: await bcrypt.hash('cashier123', 10),
        full_name: 'Cashier One',
        role: UserRole.CASHIER,
      },
    ]);
    console.log('Users seeded (admin/admin123, cashier1/cashier123)');
  } else {
    console.log('Users already exist, skipping');
  }

  // Seed Categories
  const categoriesRepo = dataSource.getRepository(Category);
  const existingCats = await categoriesRepo.count();
  let bakery: Category, beverages: Category, snacks: Category;
  if (existingCats === 0) {
    [bakery, beverages, snacks] = await categoriesRepo.save([
      { name: 'Bakery' },
      { name: 'Beverages' },
      { name: 'Snacks' },
    ]);
    console.log('Categories seeded');
  } else {
    console.log('Categories already exist, skipping');
    bakery = (await categoriesRepo.findOne({ where: { name: 'Bakery' } }))!;
    beverages = (await categoriesRepo.findOne({
      where: { name: 'Beverages' },
    }))!;
    snacks = (await categoriesRepo.findOne({ where: { name: 'Snacks' } }))!;
  }

  // Seed Products
  const productsRepo = dataSource.getRepository(Product);
  const existingProducts = await productsRepo.count();
  if (existingProducts === 0) {
    await productsRepo.save([
      {
        sku: 'BAK-001',
        name: 'Chocolate Cake',
        base_price: 150,
        category_id: bakery.id,
      },
      {
        sku: 'BAK-002',
        name: 'Butter Croissant',
        base_price: 65,
        category_id: bakery.id,
      },
      {
        sku: 'BEV-001',
        name: 'Iced Latte',
        base_price: 85,
        category_id: beverages.id,
      },
      {
        sku: 'BEV-002',
        name: 'Thai Tea',
        base_price: 55,
        category_id: beverages.id,
      },
      {
        sku: 'SNK-001',
        name: 'Cookie Pack',
        base_price: 45,
        category_id: snacks.id,
      },
    ]);
    console.log('Products seeded (5 products)');
  } else {
    console.log('Products already exist, skipping');
  }

  // Seed Ingredients
  const ingredientsRepo = dataSource.getRepository(Ingredient);
  const existingIngredients = await ingredientsRepo.count();
  if (existingIngredients === 0) {
    await ingredientsRepo.save([
      { name: 'Flour', unit: 'grams', stock_qty: 10000, min_alert_qty: 1000 },
      { name: 'Butter', unit: 'grams', stock_qty: 5000, min_alert_qty: 500 },
      { name: 'Sugar', unit: 'grams', stock_qty: 8000, min_alert_qty: 1000 },
      {
        name: 'Cocoa Powder',
        unit: 'grams',
        stock_qty: 3000,
        min_alert_qty: 300,
      },
      {
        name: 'Coffee Beans',
        unit: 'grams',
        stock_qty: 5000,
        min_alert_qty: 500,
      },
      { name: 'Milk', unit: 'ml', stock_qty: 20000, min_alert_qty: 2000 },
      {
        name: 'Tea Leaves',
        unit: 'grams',
        stock_qty: 2000,
        min_alert_qty: 200,
      },
    ]);
    console.log('Ingredients seeded (7 ingredients)');
  } else {
    console.log('Ingredients already exist, skipping');
  }

  // Seed Recipes (BOM)
  const recipesRepo = dataSource.getRepository(Recipe);
  const existingRecipes = await recipesRepo.count();
  if (existingRecipes === 0) {
    const products = await productsRepo.find();
    const ingredients = await ingredientsRepo.find();

    const findProduct = (sku: string) => products.find((p) => p.sku === sku)!;
    const findIngredient = (name: string) =>
      ingredients.find((i) => i.name === name)!;

    await recipesRepo.save([
      // Chocolate Cake: 200g flour, 100g butter, 80g sugar, 50g cocoa
      {
        product_id: findProduct('BAK-001').id,
        ingredient_id: findIngredient('Flour').id,
        usage_qty: 200,
      },
      {
        product_id: findProduct('BAK-001').id,
        ingredient_id: findIngredient('Butter').id,
        usage_qty: 100,
      },
      {
        product_id: findProduct('BAK-001').id,
        ingredient_id: findIngredient('Sugar').id,
        usage_qty: 80,
      },
      {
        product_id: findProduct('BAK-001').id,
        ingredient_id: findIngredient('Cocoa Powder').id,
        usage_qty: 50,
      },
      // Butter Croissant: 150g flour, 80g butter
      {
        product_id: findProduct('BAK-002').id,
        ingredient_id: findIngredient('Flour').id,
        usage_qty: 150,
      },
      {
        product_id: findProduct('BAK-002').id,
        ingredient_id: findIngredient('Butter').id,
        usage_qty: 80,
      },
      // Iced Latte: 18g coffee beans, 200ml milk, 10g sugar
      {
        product_id: findProduct('BEV-001').id,
        ingredient_id: findIngredient('Coffee Beans').id,
        usage_qty: 18,
      },
      {
        product_id: findProduct('BEV-001').id,
        ingredient_id: findIngredient('Milk').id,
        usage_qty: 200,
      },
      {
        product_id: findProduct('BEV-001').id,
        ingredient_id: findIngredient('Sugar').id,
        usage_qty: 10,
      },
      // Thai Tea: 15g tea leaves, 150ml milk, 20g sugar
      {
        product_id: findProduct('BEV-002').id,
        ingredient_id: findIngredient('Tea Leaves').id,
        usage_qty: 15,
      },
      {
        product_id: findProduct('BEV-002').id,
        ingredient_id: findIngredient('Milk').id,
        usage_qty: 150,
      },
      {
        product_id: findProduct('BEV-002').id,
        ingredient_id: findIngredient('Sugar').id,
        usage_qty: 20,
      },
    ]);
    console.log('Recipes (BOM) seeded');
  } else {
    console.log('Recipes already exist, skipping');
  }

  await dataSource.destroy();
  console.log('Seed complete!');
}

seed().catch((err) => {
  console.error('Seed failed:', err);
  process.exit(1);
});
