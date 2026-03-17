<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('items', function (Blueprint $table) {
            $table->string('brand')->nullable()->after('name');
            $table->decimal('price', 10, 2)->nullable()->after('brand');
            $table->integer('stock')->default(0)->after('price');
            $table->string('image_url')->nullable()->after('stock');
        });
    }

    public function down(): void
    {
        Schema::table('items', function (Blueprint $table) {
            $table->dropColumn(['brand', 'price', 'stock', 'image_url']);
        });
    }
};
