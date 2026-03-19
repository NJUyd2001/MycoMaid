shader_type canvas_item;

// --- 属性设置 ---
// 描边颜色 (默认白色)
uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
// 描边宽度 (像素)
uniform float width : hint_range(0.0, 10.0) = 1.0;
// 开关：代码里控制这个变量来开启/关闭描边
uniform bool is_active = false;

void fragment() {
    // 获取当前像素的颜色
    vec4 col = texture(TEXTURE, UV);

    // 如果开关没开，或者当前像素本身就是不透明的(是建筑本体)，就直接显示原样，不浪费算力
    if (!is_active || col.a > 0.1) {
        COLOR = col;
    } else {
        // --- 描边计算逻辑 ---

        // 获取纹理单个像素在 UV 坐标系中的大小
        vec2 size = TEXTURE_PIXEL_SIZE * width;

        // 累加周围 4 个方向 (上、下、左、右) 的透明度
        float a = 0.0;
        a += texture(TEXTURE, UV + vec2(0.0, -size.y)).a; // 上
        a += texture(TEXTURE, UV + vec2(0.0, size.y)).a;  // 下
        a += texture(TEXTURE, UV + vec2(-size.x, 0.0)).a; // 左
        a += texture(TEXTURE, UV + vec2(size.x, 0.0)).a;  // 右

        // 如果想让描边更圆润，可以把下面这 4 行注释解开 (检测对角线)
        // a += texture(TEXTURE, UV + vec2(-size.x, -size.y)).a;
        // a += texture(TEXTURE, UV + vec2(size.x, size.y)).a;
        // a += texture(TEXTURE, UV + vec2(-size.x, size.y)).a;
        // a += texture(TEXTURE, UV + vec2(size.x, -size.y)).a;

        // 如果周围有不透明的东西 (a > 0)，说明这里是边缘，画上描边色
        if (a > 0.0) {
            COLOR = outline_color;
        } else {
            // 否则保持透明
            COLOR = col;
        }
    }
}