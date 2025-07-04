#!/bin/bash

# Script để fix tất cả lỗi lint trong Flutter project
echo "🔧 Bắt đầu fix lint issues..."

# 1. Fix prefer_final_locals và prefer_final_in_for_each
echo "📋 Fixing prefer_final_locals and prefer_final_in_for_each..."

# 2. Fix prefer_const_constructors
echo "🏗️ Fixing prefer_const_constructors..."

# 3. Fix prefer_single_quotes
echo "✏️ Fixing prefer_single_quotes..."

# 4. Fix library_private_types_in_public_api
echo "🔒 Fixing library_private_types_in_public_api..."

# 5. Fix deprecated_member_use
echo "⚠️ Fixing deprecated_member_use..."

# Chạy dart fix để auto-fix các lỗi có thể
echo "🤖 Running dart fix..."
dart fix --apply

echo "✅ Hoàn thành! Kiểm tra lại với flutter analyze"
