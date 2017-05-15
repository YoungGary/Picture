# Picture
demo主要是图片的美白和灰色的实践
主要原理:<br />
美白<br />
创建CGColorSpaceRef 颜色空间 遍历所有像素点 改变RGBA<br />
灰色 <br />
创建灰色的颜色空间上下文 绘制新的 图片赋值