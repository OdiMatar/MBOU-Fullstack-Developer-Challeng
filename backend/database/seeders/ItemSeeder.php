<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Item;

class ItemSeeder extends Seeder
{
    public function run(): void
    {
        // Verwijder oude producten
        Item::truncate();
        
        $products = [
            [
                'name' => 'iPhone 15 Pro Max',
                'description' => '6.7" Super Retina XDR display met ProMotion technologie. A17 Pro chip voor ultieme prestaties. Titanium design met actieknop. Triple camera systeem met 48MP hoofdcamera, 5x optische zoom en nachtmodus. Batterijduur tot 29 uur video. 5G ready.',
                'brand' => 'Apple',
                'price' => 1299.99,
                'stock' => 15,
                'color' => 'Titanium Blauw',
                'image_url' => 'https://images.unsplash.com/photo-1695048133142-1a20484d2569?w=400&h=400&fit=crop',
            ],
            [
                'name' => 'Samsung Galaxy S24 Ultra',
                'description' => '6.8" Dynamic AMOLED 2X scherm met 120Hz. Snapdragon 8 Gen 3 processor. S Pen ingebouwd voor productiviteit. 200MP camera met AI zoom tot 100x. 5000mAh batterij met snelladen. IP68 waterdicht. Gorilla Glass Victus 2.',
                'brand' => 'Samsung',
                'price' => 1199.99,
                'stock' => 12,
                'color' => 'Phantom Zwart',
                'image_url' => 'https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?w=400&h=400&fit=crop',
            ],
            [
                'name' => 'Google Pixel 8 Pro',
                'description' => '6.7" LTPO OLED display met 120Hz. Google Tensor G3 chip met AI features. Magic Eraser en Best Take camera functies. 50MP hoofdcamera met Real Tone. 7 jaar software updates gegarandeerd. Pure Android 14 ervaring.',
                'brand' => 'Google',
                'price' => 899.99,
                'stock' => 8,
                'color' => 'Obsidian Zwart',
                'image_url' => 'https://images.unsplash.com/photo-1598327105666-5b89351aff97?w=400&h=400&fit=crop',
            ],
            [
                'name' => 'OnePlus 12',
                'description' => '6.82" AMOLED scherm met 120Hz ProXDR. Snapdragon 8 Gen 3 processor. 100W SuperVOOC snelladen (0-100% in 26 min). Hasselblad camera systeem met 50MP Sony sensor. OxygenOS 14 gebaseerd op Android 14. 5400mAh batterij.',
                'brand' => 'OnePlus',
                'price' => 799.99,
                'stock' => 20,
                'color' => 'Flowy Emerald',
                'image_url' => 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=400&h=400&fit=crop',
            ],
            [
                'name' => 'Xiaomi 14 Pro',
                'description' => '6.73" AMOLED display met Dolby Vision. Snapdragon 8 Gen 3 chipset. Leica Summilux lens met variabele diafragma. 120W HyperCharge technologie. 50MP triple camera setup. MIUI 15 met Android 14. Premium keramische achterkant.',
                'brand' => 'Xiaomi',
                'price' => 699.99,
                'stock' => 25,
                'color' => 'Titanium Grijs',
                'image_url' => 'https://images.unsplash.com/photo-1592286927505-b0501739c110?w=400&h=400&fit=crop',
            ],
            [
                'name' => 'iPhone 14',
                'description' => '6.1" Super Retina XDR display. A15 Bionic chip met 5-core GPU. Dual camera systeem met 12MP hoofdcamera en ultrawide. Crash Detection en Emergency SOS via satelliet. Ceramic Shield voorkant. Tot 20 uur video afspelen.',
                'brand' => 'Apple',
                'price' => 799.99,
                'stock' => 10,
                'color' => 'Paars',
                'image_url' => 'https://images.unsplash.com/photo-1663499482523-1c0d8c469e15?w=400&h=400&fit=crop',
            ],
            [
                'name' => 'Samsung Galaxy A54',
                'description' => '6.4" Super AMOLED scherm met 120Hz. Exynos 1380 processor. Triple camera met 50MP OIS hoofdcamera. 5000mAh batterij met 25W snelladen. IP67 water- en stofbestendig. Gorilla Glass 5. Uitstekende prijs-kwaliteit verhouding.',
                'brand' => 'Samsung',
                'price' => 449.99,
                'stock' => 30,
                'color' => 'Awesome Violet',
                'image_url' => 'https://images.unsplash.com/photo-1585060544812-6b45742d762f?w=400&h=400&fit=crop',
            ],
            [
                'name' => 'Nothing Phone 2',
                'description' => '6.7" LTPO OLED display met 120Hz. Snapdragon 8+ Gen 1 processor. Unieke Glyph Interface met LED verlichting op achterkant. 50MP dual camera systeem. Nothing OS 2.0 gebaseerd op Android 13. Draadloos opladen en reverse charging.',
                'brand' => 'Nothing',
                'price' => 599.99,
                'stock' => 18,
                'color' => 'Wit',
                'image_url' => 'https://images.unsplash.com/photo-1556656793-08538906a9f8?w=400&h=400&fit=crop',
            ],
            [
                'name' => 'iPhone 13 Pro',
                'description' => '6.1" Super Retina XDR met ProMotion 120Hz. A15 Bionic chip. Pro camera systeem met 3x optische zoom. Cinematic mode voor video. LiDAR scanner voor AR. Roestvrij stalen frame. Tot 22 uur video afspelen. 5G connectiviteit.',
                'brand' => 'Apple',
                'price' => 899.99,
                'stock' => 7,
                'color' => 'Sierra Blauw',
                'image_url' => 'https://images.unsplash.com/photo-1632661674596-df8be070a5c5?w=400&h=400&fit=crop',
            ],
            [
                'name' => 'Oppo Find X6 Pro',
                'description' => '6.82" AMOLED display met 120Hz. Snapdragon 8 Gen 2 processor. Hasselblad camera systeem met 50MP Sony IMX989 sensor. 100W SuperVOOC en 50W draadloos opladen. ColorOS 13.1 op Android 13. Premium vegan leather achterkant optie.',
                'brand' => 'Oppo',
                'price' => 749.99,
                'stock' => 14,
                'color' => 'Desert Silver',
                'image_url' => 'https://images.unsplash.com/photo-1567581935884-3349723552ca?w=400&h=400&fit=crop',
            ],
        ];

        foreach ($products as $product) {
            Item::create($product);
        }
    }
}
