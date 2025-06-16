# simple OCR
class ColabOCREvaluator:
    """適用於 Google Colab 的 OCR 評估系統"""
    
    def __init__(self):
        self.folders = folders
        self.ground_truths = {}
        self.results = []
        self.tesseract_config = '--oem 0 --psm 6 -l chi_tra'
        
    def load_ground_truth(self):
        """載入標準答案"""
        print("載入標準答案...")
        
        truth_files = {
            'A': 'A_truth.txt',
            'B': 'B_truth.txt', 
            'C': 'C_truth.txt'
        }
        
        for key, filename in truth_files.items():
            filepath = os.path.join(self.folders['ground_truth'], filename)
            if os.path.exists(filepath):
                with open(filepath, 'r', encoding='utf-8') as f:
                    content = f.read().strip()
                    # 只保留中文字符
                    cleaned_content = re.sub(r'[^\u4e00-\u9fff]', '', content)
                    self.ground_truths[key] = cleaned_content
                    print(f"   ✓ {key}: {cleaned_content[:20]}...")
            else:
                print(f"   ✗ 找不到 {filename}")
                self.ground_truths[key] = ""
    
    def basic_ocr(self, image_path):
        """基礎 OCR 識別"""
        try:
            image = cv2.imread(image_path)
            if image is None:
                return ""
            
            # 轉換格式
            image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
            pil_image = Image.fromarray(image_rgb)
            
            # 執行 OCR
            result = pytesseract.image_to_string(
                pil_image, 
                config=self.tesseract_config
            )
            
            # 清理結果
            cleaned = re.sub(r'[^\u4e00-\u9fff]', '', result)
            return cleaned
            
        except Exception as e:
            print(f"OCR 錯誤 {image_path}: {e}")
            return ""
    
    def calculate_accuracy(self, recognized, ground_truth):
        """計算準確率"""
        if not ground_truth or not recognized:
            return 0.0
        
        # 計算編輯距離
        def levenshtein(s1, s2):
            if len(s1) < len(s2):
                return levenshtein(s2, s1)
            if len(s2) == 0:
                return len(s1)
            
            previous_row = list(range(len(s2) + 1))
            for i, c1 in enumerate(s1):
                current_row = [i + 1]
                for j, c2 in enumerate(s2):
                    insertions = previous_row[j + 1] + 1
                    deletions = current_row[j] + 1
                    substitutions = previous_row[j] + (c1 != c2)
                    current_row.append(min(insertions, deletions, substitutions))
                previous_row = current_row
            return previous_row[-1]
        
        edit_dist = levenshtein(recognized, ground_truth)
        max_len = max(len(recognized), len(ground_truth))
        
        accuracy = max(0, (max_len - edit_dist) / max_len) if max_len > 0 else 0
        return accuracy
    
    def evaluate_baseline(self):
        """評估原始影像基準性能"""
        print("\n評估原始影像基準性能...")
        
        baseline = {}
        for file_key in ['A', 'B', 'C']:
            image_path = os.path.join(self.folders['original'], f"{file_key}.png")
            
            if os.path.exists(image_path):
                ocr_result = self.basic_ocr(image_path)
                ground_truth = self.ground_truths.get(file_key, "")
                accuracy = self.calculate_accuracy(ocr_result, ground_truth)
                
                baseline[file_key] = {
                    'ocr_result': ocr_result,
                    'accuracy': accuracy
                }
                
                print(f"   {file_key}.png: 準確率 {accuracy:.3f}")
            else:
                baseline[file_key] = {'ocr_result': "", 'accuracy': 0.0}
                print(f"   {file_key}.png: 檔案不存在")
        
        return baseline