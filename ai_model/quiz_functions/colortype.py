import cv2
import numpy as np
import matplotlib.pyplot as plt
import time

class ColorTypeAnalyzer:
    def __init__(self):
        self.face_cascade = cv2.CascadeClassifier(
            cv2.data.haarcascades + 'haarcascade_frontalface_default.xml'
        )
        
        self.color_types = {
            "Холодная Зима": {"undertone": "cool", "brightness": "medium", "season": "Зима", "subcategory": "Холодная"},
            "Тёмная Зима": {"undertone": "cool", "brightness": "dark", "season": "Зима", "subcategory": "Тёмная"},
            "Яркая Зима": {"undertone": "cool", "brightness": "medium", "saturation": "high", "season": "Зима", "subcategory": "Яркая"},
            "Холодное Лето": {"undertone": "cool", "brightness": "light", "season": "Лето", "subcategory": "Холодное"},
            "Светлое Лето": {"undertone": "cool", "brightness": "light", "saturation": "low", "season": "Лето", "subcategory": "Светлое"},
            "Мягкое Лето": {"undertone": "cool", "brightness": "medium", "saturation": "low", "season": "Лето", "subcategory": "Мягкое"},
            "Тёплая Весна": {"undertone": "warm", "brightness": "light", "season": "Весна", "subcategory": "Тёплая"},
            "Светлая Весна": {"undertone": "warm", "brightness": "light", "saturation": "high", "season": "Весна", "subcategory": "Светлая"},
            "Яркая Весна": {"undertone": "warm", "brightness": "medium", "saturation": "high", "season": "Весна", "subcategory": "Яркая"},
            "Тёплая Осень": {"undertone": "warm", "brightness": "medium", "season": "Осень", "subcategory": "Тёплая"},
            "Мягкая Осень": {"undertone": "warm", "brightness": "medium", "saturation": "low", "season": "Осень", "subcategory": "Мягкая"},
            "Тёмная Осень": {"undertone": "warm", "brightness": "dark", "season": "Осень", "subcategory": "Тёмная"},
        }

    def analyze_photo(self, image_path: str) -> dict:
        image = cv2.imread(image_path)
        if image is None:
            raise ValueError(f"Не удалось загрузить фото: {image_path}")
        
        return self._analyze_image(image)

    def analyze_from_camera(self) -> dict:
        """Анализ цветотипа через камеру"""
        cap = cv2.VideoCapture(0)
        
        if not cap.isOpened():
            raise Exception("Не удалось открыть камеру. Проверьте подключение.")
        
        print("\n📸 КАМЕРА АКТИВИРОВАНА")
        print("📋 ИНСТРУКЦИЯ:")
        print("  • Расположите лицо внутри овала")
        print("  • Смотрите прямо в камеру")
        print("  • Обеспечьте хорошее освещение")
        print("  • Нажмите ПРОБЕЛ для анализа")
        print("  • ESC для выхода\n")
        
        face_detected_time = 0
        stable_face_frames = 0
        
        while True:
            ret, frame = cap.read()
            if not ret:
                break
            
            # Зеркалим для удобства
            frame = cv2.flip(frame, 1)
            frame_display = frame.copy()
            
            # Конвертируем в серый для детекции
            gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
            faces = self.face_cascade.detectMultiScale(
                gray, scaleFactor=1.1, minNeighbors=5, minSize=(100, 100)
            )
            
            # Рисуем маску (овал) по центру
            h, w = frame.shape[:2]
            center_x, center_y = w // 2, h // 2
            oval_radius_x, oval_radius_y = w // 4, h // 3
            
            # Рисуем направляющий овал
            cv2.ellipse(frame_display, 
                       (center_x, center_y), 
                       (oval_radius_x, oval_radius_y), 
                       0, 0, 360, 
                       (255, 100, 100), 2)
            
            # Рисуем крестик по центру
            cv2.line(frame_display, (center_x - 10, center_y), (center_x + 10, center_y), (255, 100, 100), 2)
            cv2.line(frame_display, (center_x, center_y - 10), (center_x, center_y + 10), (255, 100, 100), 2)
            
            # Текст инструкции
            cv2.putText(frame_display, "Нажмите ПРОБЕЛ для анализа", 
                       (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (255, 255, 255), 2)
            
            if len(faces) > 0:
                # Берём самое крупное лицо
                x, y, w_face, h_face = max(faces, key=lambda f: f[2] * f[3])
                
                # Проверяем, находится ли лицо в центре (в овале)
                face_center_x = x + w_face // 2
                face_center_y = y + h_face // 2
                
                distance_from_center = ((face_center_x - center_x) ** 2 + 
                                       (face_center_y - center_y) ** 2) ** 0.5
                
                # Рисуем рамку вокруг лица
                color = (0, 255, 0) if distance_from_center < 50 else (0, 255, 255)
                cv2.rectangle(frame_display, (x, y), (x + w_face, y + h_face), color, 3)
                
                # Проверяем размер лица (должно быть достаточно крупным)
                face_size_ok = w_face > 150 and h_face > 150
                
                if distance_from_center < 50 and face_size_ok:
                    stable_face_frames += 1
                    progress = min(stable_face_frames / 30, 1.0)  # 30 кадров = 1 секунда
                    
                    # Прогресс-бар
                    bar_width = int(200 * progress)
                    cv2.rectangle(frame_display, (w//2 - 100, h - 60), 
                                 (w//2 - 100 + bar_width, h - 40), (0, 255, 0), -1)
                    cv2.rectangle(frame_display, (w//2 - 100, h - 60), 
                                 (w//2 + 100, h - 40), (255, 255, 255), 2)
                    
                    if stable_face_frames >= 30:  # Лицо стабильно 1 секунду
                        face_detected_time += 1
                        if face_detected_time >= 1:  # Ждём 1 секунду после стабилизации
                            # Автоматический захват!
                            print("✅ Лицо зафиксировано! Анализирую...")
                            face_image = frame[y:y+h_face, x:x+w_face]
                            cap.release()
                            cv2.destroyAllWindows()
                            return self._analyze_image(cv2.cvtColor(face_image, cv2.COLOR_BGR2RGB))
                else:
                    stable_face_frames = 0
                    face_detected_time = 0
                    
                    # Подсказка
                    if not face_size_ok:
                        cv2.putText(frame_display, "Приблизьтесь к камере", 
                                   (10, 60), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 255), 2)
                    else:
                        cv2.putText(frame_display, "Расположите лицо в центре", 
                                   (10, 60), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 255), 2)
            else:
                stable_face_frames = 0
                face_detected_time = 0
                cv2.putText(frame_display, "Лицо не найдено", 
                           (10, 60), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 0, 255), 2)
            
            cv2.imshow('📸 Сканирование цветотипа', frame_display)
            
            key = cv2.waitKey(1) & 0xFF
            if key == 27:  # ESC
                break
            elif key == 32:  # ПРОБЕЛ - ручной захват
                if len(faces) > 0:
                    print("📸 Захват по команде...")
                    x, y, w_face, h_face = max(faces, key=lambda f: f[2] * f[3])
                    face_image = frame[y:y+h_face, x:x+w_face]
                    cap.release()
                    cv2.destroyAllWindows()
                    return self._analyze_image(cv2.cvtColor(face_image, cv2.COLOR_BGR2RGB))
        
        cap.release()
        cv2.destroyAllWindows()
        raise Exception("Сканирование отменено")

    def _analyze_image(self, image_rgb) -> dict:
        """Внутренний метод анализа изображения (numpy array)"""
        gray = cv2.cvtColor(image_rgb, cv2.COLOR_RGB2GRAY)
        
        faces = self.face_cascade.detectMultiScale(
            gray, scaleFactor=1.1, minNeighbors=5, minSize=(30, 30)
        )
        
        if len(faces) == 0:
            raise ValueError("❌ Лицо не найдено на фото.")
        
        x, y, w, h = max(faces, key=lambda f: f[2] * f[3])
        face_image = image_rgb[y:y+h, x:x+w]
        
        # Сохраняем фото для отладки
        cv2.imwrite('captured_face.jpg', cv2.cvtColor(face_image, cv2.COLOR_RGB2BGR))
        print("💾 Фото сохранено как 'captured_face.jpg'")
        
        skin_color = self._analyze_skin_color(face_image)
        hair_color = self._analyze_hair_color(face_image)
        eye_color = self._analyze_eye_color(face_image)
        
        color_type = self._determine_color_type(skin_color, hair_color, eye_color)
        
        return {
            "skin_color": skin_color,
            "hair_color": hair_color,
            "eye_color": eye_color,
            "color_type": color_type,
        }
    
    def _analyze_skin_color(self, face_image):
        h, w, _ = face_image.shape
        cheek_area = face_image[h//3:2*h//3, w//4:3*w//4]
        
        pixels = cheek_area.reshape(-1, 3)
        filtered = [p for p in pixels if 100 < sum(p)/3 < 220]
        
        if not filtered:
            return (200, 160, 140)
        
        avg = np.mean(filtered, axis=0)
        return (int(avg[0]), int(avg[1]), int(avg[2]))
    
    def _analyze_hair_color(self, face_image):
        h, w, _ = face_image.shape
        hair_area = face_image[0:h//3, :]
        
        pixels = hair_area.reshape(-1, 3)
        dark = [p for p in pixels if sum(p)/3 < 100]
        
        if not dark:
            return (50, 40, 30)
        
        avg = np.mean(dark, axis=0)
        return (int(avg[0]), int(avg[1]), int(avg[2]))
    
    def _analyze_eye_color(self, face_image):
        h, w, _ = face_image.shape
        eye_area = face_image[h//4:h//2, w//4:3*w//4]
        
        pixels = eye_area.reshape(-1, 3)
        colored = [p for p in pixels if 60 < sum(p)/3 < 180]
        
        if not colored:
            return (120, 90, 60)
        
        avg = np.mean(colored, axis=0)
        return (int(avg[0]), int(avg[1]), int(avg[2]))
    
    def _determine_color_type(self, skin, hair, eyes):
        """
        Улучшенное определение цветотипа с учётом кожи, волос и глаз
        Возвращает разные результаты для разных комбинаций цветов
        """
        
        def rgb_to_lab(r, g, b):
            r, g, b = r/255.0, g/255.0, b/255.0
            # Gamma correction
            r = ((r + 0.055) / 1.055) ** 2.4 if r > 0.04045 else r / 12.92
            g = ((g + 0.055) / 1.055) ** 2.4 if g > 0.04045 else g / 12.92
            b = ((b + 0.055) / 1.055) ** 2.4 if b > 0.04045 else b / 12.92
            # XYZ
            x = r * 0.4124 + g * 0.3576 + b * 0.1805
            y = r * 0.2126 + g * 0.7152 + b * 0.0722
            z = r * 0.0193 + g * 0.1192 + b * 0.9505
            x, y, z = x/0.95047, y/1.0, z/1.08883
            # LAB
            x = x**(1/3) if x > 0.008856 else (7.787*x + 16/116)
            y = y**(1/3) if y > 0.008856 else (7.787*y + 16/116)
            z = z**(1/3) if z > 0.008856 else (7.787*z + 16/116)
            L = (116 * y) - 16
            a = 500 * (x - y)
            b_val = 200 * (y - z)
            return L, a, b_val
        
        skin_L, skin_a, skin_b = rgb_to_lab(*skin)
        hair_L, hair_a, hair_b = rgb_to_lab(*hair)
        eye_L, eye_a, eye_b = rgb_to_lab(*eyes)
        
        if skin_a > 3:
            undertone = "warm"
        elif skin_a < -3:
            undertone = "cool"
        else:
            undertone = "neutral"
        
        contrast = abs(skin_L - hair_L)
        if contrast > 45:
            contrast_level = "very_high"
        elif contrast > 30:
            contrast_level = "high"
        elif contrast > 15:
            contrast_level = "medium"
        else:
            contrast_level = "low"
        
        eye_saturation = abs(eye_a) + abs(eye_b)
        if eye_saturation > 55:
            saturation_level = "very_high"
        elif eye_saturation > 35:
            saturation_level = "high"
        elif eye_saturation > 20:
            saturation_level = "medium"
        else:
            saturation_level = "low"
        
        # 4. Яркость волос
        hair_brightness = sum(hair) / 3
        hair_dark = hair_brightness < 85
        
        # 5. Яркость кожи
        skin_brightness = sum(skin) / 3
        if skin_brightness > 180:
            skin_brightness_level = "light"
        elif skin_brightness > 140:
            skin_brightness_level = "medium"
        else:
            skin_brightness_level = "dark"
        
        # 6. Золотистый оттенок (для Осени): высокий b* в коже
        golden_undertone = skin_b > 12
        
        # 7. Приглушённые тона: низкая насыщенность + низкий контраст
        muted = (eye_saturation < 25) and (contrast_level in ["low", "medium"])
        
        # 8. Яркие глаза
        bright_eyes = eye_saturation > 45
        
        # 🎯 Профили 12 цветотипов с весами
        profiles = {
            "Холодная Зима": {
                "undertone": "cool", "contrast": "high", "saturation": "high",
                "hair_dark": True, "bright_eyes": False, "weight": 1.0,
                "season": "Зима", "subcategory": "Холодная"
            },
            "Тёмная Зима": {
                "undertone": "cool", "contrast": "high", "saturation": "medium",
                "hair_dark": True, "brightness": "dark", "weight": 1.0,
                "season": "Зима", "subcategory": "Тёмная"
            },
            "Яркая Зима": {
                "undertone": "cool", "contrast": "very_high", "saturation": "very_high",
                "hair_dark": True, "bright_eyes": True, "weight": 1.0,
                "season": "Зима", "subcategory": "Яркая"
            },
            "Холодное Лето": {
                "undertone": "cool", "contrast": "low", "saturation": "low",
                "hair_dark": False, "weight": 1.0,
                "season": "Лето", "subcategory": "Холодное"
            },
            "Светлое Лето": {
                "undertone": "cool", "contrast": "low", "saturation": "medium",
                "brightness": "light", "weight": 1.0,
                "season": "Лето", "subcategory": "Светлое"
            },
            "Мягкое Лето": {
                "undertone": "cool", "contrast": "low", "saturation": "low",
                "muted": True, "weight": 1.0,
                "season": "Лето", "subcategory": "Мягкое"
            },
            "Тёплая Весна": {
                "undertone": "warm", "contrast": "medium", "saturation": "medium",
                "hair_dark": False, "brightness": "light", "weight": 1.0,
                "season": "Весна", "subcategory": "Тёплая"
            },
            "Светлая Весна": {
                "undertone": "warm", "contrast": "low", "saturation": "high",
                "hair_dark": False, "brightness": "light", "weight": 1.0,
                "season": "Весна", "subcategory": "Светлая"
            },
            "Яркая Весна": {
                "undertone": "warm", "contrast": "high", "saturation": "very_high",
                "hair_dark": False, "bright_eyes": True, "weight": 1.0,
                "season": "Весна", "subcategory": "Яркая"
            },
            "Тёплая Осень": {
                "undertone": "warm", "contrast": "medium", "saturation": "high",
                "hair_dark": True, "golden": True, "weight": 1.0,
                "season": "Осень", "subcategory": "Тёплая"
            },
            "Мягкая Осень": {
                "undertone": "warm", "contrast": "low", "saturation": "low",
                "hair_dark": True, "muted": True, "weight": 1.0,
                "season": "Осень", "subcategory": "Мягкая"
            },
            "Тёмная Осень": {
                "undertone": "warm", "contrast": "medium", "saturation": "medium",
                "hair_dark": True, "brightness": "dark", "weight": 1.0,
                "season": "Осень", "subcategory": "Тёмная"
            },
        }
        
        # Считаем совпадения с весами
        best_match = None
        best_score = -1
        
        for type_name, profile in profiles.items():
            score = 0
            
            # Подтон кожи (самое важное) — 3 балла
            if profile["undertone"] == undertone:
                score += 3 * profile["weight"]
            elif profile["undertone"] == "neutral":
                score += 1 * profile["weight"]
            
            # Контраст кожа-волосы — 2 балла
            if profile.get("contrast") == contrast_level:
                score += 2
            elif profile.get("contrast") == "very_high" and contrast_level == "high":
                score += 1  # Частичное совпадение
            
            # Насыщенность (по глазам) — 2 балла
            if profile.get("saturation") == saturation_level:
                score += 2
            elif profile.get("saturation") == "high" and saturation_level == "very_high":
                score += 1
            
            # Тёмные/светлые волосы — 1 балл
            if "hair_dark" in profile:
                if profile["hair_dark"] == hair_dark:
                    score += 1
            
            # Яркость кожи — 1 балл
            if "brightness" in profile:
                if profile["brightness"] == skin_brightness_level:
                    score += 1
            
            # Золотистый оттенок (Осень) — 1 балл
            if profile.get("golden") and golden_undertone:
                score += 1
            
            # Приглушённые тона (Мягкие) — 1 балл
            if profile.get("muted") and muted:
                score += 1
            
            # Яркие глаза (Яркие) — 1 балл
            if profile.get("bright_eyes") and bright_eyes:
                score += 1
            
            if score > best_score:
                best_score = score
                best_match = {
                    "name": type_name,
                    "season": profile["season"],
                    "subcategory": profile["subcategory"],
                    # Реалистичная уверенность: 55% минимум, 95% максимум
                    "confidence": min(0.55 + (best_score / 14) * 0.40, 0.95),
                    "score": best_score  # Для отладки
                }
        
        return best_match


def main():
    print("=" * 60)
    print("🎨 АНАЛИЗАТОР ЦВЕТОТИПА")
    print("=" * 60)
    
    analyzer = ColorTypeAnalyzer()
    
    print("\nВыберите способ анализа:")
    print("1. 📸 С камеры (рекомендуется)")
    print("2. 📁 С фото")
    
    choice = input("\nВведите номер (1 или 2): ").strip()
    
    try:
        if choice == "1":
            print("\n⏳ Запуск камеры...")
            result = analyzer.analyze_from_camera()
        elif choice == "2":
            photo_path = input("📁 Введите путь к фото: ").strip()
            if not photo_path:
                photo_path = "photo.jpg"
            print("\n⏳ Анализирую...")
            result = analyzer.analyze_photo(photo_path)
        else:
            print("❌ Неверный выбор")
            return
        
        print("\n" + "=" * 60)
        print("✨ РЕЗУЛЬТАТ")
        print("=" * 60)
        print(f"\n🎨 Цвет кожи: RGB{result['skin_color']}")
        print(f"💇 Цвет волос: RGB{result['hair_color']}")
        print(f"👁️  Цвет глаз: RGB{result['eye_color']}")
        
        print("\n" + "=" * 60)
        print(f"🌟 ВАШ ЦВЕТОТИП: {result['color_type']['name']}")
        print("=" * 60)
        print(f"📅 Сезон: {result['color_type']['season']}")
        print(f"🎭 Подтип: {result['color_type']['subcategory']}")
        print(f"📊 Уверенность: {result['color_type']['confidence']*100:.0f}%")
        
        print("\n" + "=" * 60)
        print("💡 РЕКОМЕНДАЦИИ ПО ЦВЕТАМ")
        print("=" * 60)
        
        season = result['color_type']['season']
        if season == "Зима":
            print("✅ Ваши цвета: чёрный, белый, ярко-синий, изумрудный, фуксия")
            print("❌ Избегайте: пастельных, приглушённых, оранжевых оттенков")
        elif season == "Весна":
            print("✅ Ваши цвета: персиковый, коралловый, золотистый, бирюзовый")
            print("❌ Избегайте: чёрного, тёмно-синего, холодных оттенков")
        elif season == "Лето":
            print("✅ Ваши цвета: пастельные, серо-голубой, лавандовый, мятный")
            print("❌ Избегайте: ярких, насыщенных, оранжевых оттенков")
        elif season == "Осень":
            print("✅ Ваши цвета: терракотовый, оливковый, горчичный, коричневый")
            print("❌ Избегайте: ярких холодных, чёрного, белого")
        
        show_plot = input("\n📊 Показать цвета на графике? (y/n): ").strip().lower()
        if show_plot == 'y':
            fig, axes = plt.subplots(1, 3, figsize=(10, 4))
            colors = [
                (result['skin_color'], "Цвет кожи"),
                (result['hair_color'], "Цвет волос"),
                (result['eye_color'], "Цвет глаз")
            ]
            for ax, (color, title) in zip(axes, colors):
                ax.imshow([[color]], interpolation='nearest')
                ax.set_title(f"{title}\nRGB{color}")
                ax.axis('off')
            plt.tight_layout()
            plt.show()
        
    except Exception as e:
        print(f"\n❌ Ошибка: {e}")


if __name__ == "__main__":
    main()