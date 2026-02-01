shader_type canvas_item;

// 这是一个 0 到 1.5 的值，控制圆的大小
// 1.5 是因为屏幕长宽比的原因，1.0 可能盖不住四个角
uniform float circle_size : hint_range(0.0, 1.5) = 1.05;
uniform float screen_width = 1920.0;
uniform float screen_height = 1080.0;

void fragment() {
	// 计算当前像素距离中心点的距离
	// 为了保证是正圆而不是椭圆，我们需要根据屏幕长宽比修正坐标
	float ratio = screen_width / screen_height;
	float dist = distance(vec2(UV.x * ratio, UV.y), vec2(0.5 * ratio, 0.5));

	// 如果距离大于圆的大小，就显示黑色(alpha=1)，否则透明(alpha=0)
	// 使用 step 函数产生硬边效果，如果想要边缘模糊可以用 smoothstep
	COLOR.a = step(circle_size, dist);
}