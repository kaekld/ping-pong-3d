shader_type canvas_item;

// Parámetros ajustables en el inspector de Godot
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform int blur_radius : hint_range(1, 16) = 8;     // Radio del kernel de desenfoque (cuántos píxeles leer)
uniform float blur_strength : hint_range(0.1, 10.0) = 2.0; // Intensidad de la curva Gaussiana (sigma)

// Función de peso Gaussiano (curva de campana)
float gaussian_weight(float i, float sigma) {
    // La fórmula de la distribución normal (Gaussiana) 1D
    return exp(-0.5 * (i * i) / (sigma * sigma));
}

// Función para calcular el kernel y asegurar que los pesos sumen 1.0
void calculate_kernel(out float kernel[16], int radius, float sigma) {
    // Solo necesitamos calcular la mitad del kernel (0 a radius), ya que es simétrico
    float sum = 0.0;
    
    // El tamaño máximo del kernel aquí es 16. Si aumentas 'blur_radius' más allá de 16,
    // debes aumentar el tamaño de 'kernel[16]' a ese valor.
    
    for (int i = 0; i < 16; i++) {
        // Establecer los pesos no utilizados en 0
        kernel[i] = 0.0;
    }
    
    for (int i = 0; i <= radius; i++) {
        kernel[i] = gaussian_weight(float(i), sigma);
        // El peso del centro (i=0) se suma una vez. Los demás (i>0) se suman dos veces (por el lado positivo y negativo).
        sum += i == 0 ? kernel[i] : 2.0 * kernel[i]; 
    }
    
    // Normalizar el kernel: dividir cada peso por la suma total para que la suma sea 1.0
    for (int i = 0; i <= radius; i++) {
        kernel[i] /= sum;
    }
}


void fragment() {
    vec2 uv = SCREEN_UV;
    vec2 resolution = SCREEN_PIXEL_SIZE; // Tamaño de 1 píxel
    
    // Kernel para los pesos Gaussianos (solo se usan los primeros 'blur_radius' + 1 elementos)
    float kernel[16];
    calculate_kernel(kernel, blur_radius, blur_strength);

    // Inicializar el color final. Aquí es donde se resuelve el error 'final_color'.
    vec4 final_color = vec4(0.0);
    float total_weight = 0.0; // Para la normalización, aunque el kernel ya está normalizado.

    // Aplicar desenfoque Gaussiano en el espacio 2D (menos eficiente que 2 pasadas)
    for (int x = -blur_radius; x <= blur_radius; x++) {
        for (int y = -blur_radius; y <= blur_radius; y++) {
            
            // Usar la parte absoluta de x e y para el índice del kernel (es simétrico)
            float weight_x = kernel[abs(x)];
            float weight_y = kernel[abs(y)];
            float weight = weight_x * weight_y; // Peso 2D es el producto de los pesos 1D

            vec2 offset = vec2(float(x), float(y)) * resolution;
            
            vec4 sample_color = texture(SCREEN_TEXTURE, uv + offset);
            final_color += sample_color * weight;
            total_weight += weight;
        }
    }
    
    
    COLOR = final_color;
}