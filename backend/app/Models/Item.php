<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Item extends Model
{
    protected $fillable = ['name', 'description', 'brand', 'price', 'stock', 'image_url', 'color'];
    
    protected $casts = [
        'price' => 'decimal:2',
        'stock' => 'integer',
    ];
}
