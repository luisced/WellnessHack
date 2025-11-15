#!/bin/bash

# Script para limpiar el build de Xcode y resolver errores de compilación

echo "🧹 Limpiando build de Xcode..."
echo ""

# Limpiar DerivedData
echo "📁 Borrando DerivedData..."
rm -rf ~/Library/Developer/Xcode/DerivedData
echo "   ✅ DerivedData eliminado"

# Limpiar Module Cache
echo "📁 Borrando Module Cache..."
rm -rf ~/Library/Caches/com.apple.dt.Xcode
echo "   ✅ Module Cache eliminado"

# Limpiar build folder del proyecto
echo "📁 Limpiando carpeta build del proyecto..."
cd "$(dirname "$0")"
rm -rf build/
rm -rf .build/
echo "   ✅ Build folder eliminado"

# Limpiar xcuserdata
echo "📁 Limpiando archivos de usuario..."
find . -name "*.xcuserstate" -delete
find . -name "xcuserdata" -type d -exec rm -rf {} + 2>/dev/null
echo "   ✅ User data eliminado"

echo ""
echo "✅ Build limpiado exitosamente"
echo ""
echo "📝 Próximos pasos:"
echo "1. Cierra Xcode completamente (Cmd+Q)"
echo "2. Vuelve a abrir Xcode"
echo "3. Product → Clean Build Folder (Shift+Cmd+K)"
echo "4. Product → Build (Cmd+B)"
echo ""
echo "💡 Los errores de 'CalendarEvent is ambiguous' deberían desaparecer"
echo ""
