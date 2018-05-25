---
title: Android项目开发笔记之身高年龄体重WheelView实现（单栏/双栏）
date: 2018-03-11 00:28:39
categories:
- Android
tags:
- WheelView
---
## 写在前面
　　本系列第三篇。本篇讲的是很常见的身高年龄选择器，可以定制成单栏或者双栏显示模式~
<!--more-->
## 实现效果
### 单栏
![](http://okwl1c157.bkt.clouddn.com/Android-wheelview1.png)
### 双栏
![](http://okwl1c157.bkt.clouddn.com/android-wheelview2.png)

## 步骤
### 自定义布局类
1. 新建WheelView类，继承ScrollView
2. 该类的代码我放在[gist](https://gist.github.com/Lemon-XQ/f20325c84a58f3c8e66a4efb56e1ab72)上了，主要是参考了一份别人的代码，加上一点改动。

### 初始化数据源
{% codeblock lang:java %}
    // 存储选项列表
    private ArrayList<String> heightList = new ArrayList<String>();
    private ArrayList<String> weightList = new ArrayList<String>();
    private ArrayList<String> zeroToNineList = new ArrayList<String>();
    
	private void initData(){
        // 填充列表
        heightList.clear();
        weightList.clear();
        zeroToNineList.clear();
        for (int i = 150; i <= 180; i++){
            heightList.add(i+""); // height: 150-180
        }
        for (int i = 30; i <= 150; i++){
            weightList.add(i+""); // weight: 30.0-150.0
        }
        for (int i = 0; i <= 9; i++){
            zeroToNineList.add(i+"");
        }
    }
{% endcodeblock %}

### 动态创建对话框

#### 创建身高对话框（单栏）
参数说明见后。

{% codeblock lang:java %}
heightBtn.setOnClickListener(new View.OnClickListener() {
    @Override
    public void onClick(View view) {
        showChoiceDialog(R.id.wheel_view,heightList,heightBtn,
                new WheelView.OnWheelViewListener(){
                    @Override
                    public void onSelected(int selectedIndex, String item) {
                        selectText = item;
                        height = Float.parseFloat(item)/100.0f;
                    }
                });
    }
});
{% endcodeblock %}

#### 创建体重对话框（双栏）
参数说明见后

{% codeblock lang:java %}
weightBtn.setOnClickListener(new View.OnClickListener() {
    @Override
    public void onClick(View view) {
        weight_Float = 0;
        weight_Int = 0;
        showChoiceDialog(R.id.wheel_view1, R.id.wheel_view2,
                weightList, zeroToNineList, weightBtn,
                new WheelView.OnWheelViewListener(){
                    @Override
                    public void onSelected(int selectedIndex, String item) {
                        selectText_left = item;
                        weight_Int = Integer.parseInt(item);
                        weight = weight_Int + weight_Float * 0.1f;
                        Log.d("WEIGHT",weight+"");
                    }
                },
                new WheelView.OnWheelViewListener(){
                    @Override
                    public void onSelected(int selectedIndex, String item) {
                        selectText_right = item;
                        weight_Float = Float.parseFloat(item);
                        weight = weight_Int + weight_Float * 0.1f;
                        Log.d("WEIGHT",weight+"");
                    }
                }
        );
    }
});
{% endcodeblock %}

### 对话框实现与显示

#### 单滑动标尺对话框

{% codeblock lang:java %}
private String selectText;
/**
 * 单滑动标尺对话框
 * @param wheelviewId 滑动标尺id
 * @param dataList 数据列表
 * @param infoBtn 激活对话框的按钮（用于显示所选项）
 * @param listener 标尺滑动监听器
 */
private void showChoiceDialog(int wheelviewId, ArrayList<String> dataList,
                              final Button infoBtn, WheelView.OnWheelViewListener listener){
    selectText = "";
    View outerView = LayoutInflater.from(this.getActivity()).inflate(R.layout.dialog_wheelview, null);
    final WheelView wv = outerView.findViewById(wheelviewId);
    wv.setOffset(2);// 对话框中当前项上面和下面的项数
    wv.setItems(dataList);// 设置数据源
    wv.setSeletion(3);// 默认选中第三项
    wv.setOnWheelViewListener(listener);

// 显示对话框，点击确认后将所选项的值显示到Button上
    new AlertDialog.Builder(this.getActivity())
            .setView(outerView)
            .setPositiveButton("确认",
                    new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialogInterface, int i) {
                            infoBtn.setText(selectText);
                            infoBtn.setTextColor(green);
                        }
                    })
            .setNegativeButton("取消",null)
            .show();
}
{% endcodeblock %}

#### 双滑动标尺对话框

{% codeblock lang:java %}
private String selectText_left;
private String selectText_right;
/**
 * 双滑动标尺对话框
 * @param leftwheelviewId 左滑动标尺id
 * @param rightwheelviewId 右滑动标尺id
 * @param dataList_L 左数据列表
 * @param dataList_R 右数据列表
 * @param infoBtn 激活对话框的按钮（用于显示所选项）
 * @param leftListener 左栏滑动监听器
 * @param rightListener 右栏滑动监听器
 */
private void showChoiceDialog(int leftwheelviewId, int rightwheelviewId,
                              ArrayList<String> dataList_L, ArrayList<String> dataList_R,
                              final Button infoBtn,
                              WheelView.OnWheelViewListener leftListener,
                              WheelView.OnWheelViewListener rightListener){
    selectText_left = "";
    selectText_right = "";
    View outerView = LayoutInflater.from(this.getActivity()).inflate(R.layout.dialog_twowheelview, null);
    final WheelView wv_L = outerView.findViewById(leftwheelviewId);
    wv_L.setOffset(2);// 对话框中当前项上面和下面的项数
    wv_L.setItems(dataList_L);// 设置数据源
    wv_L.setSeletion(3);// 默认初始选中第三项
    wv_L.setOnWheelViewListener(leftListener);

    final WheelView wv_R = outerView.findViewById(rightwheelviewId);
    wv_R.setOffset(2);// 对话框中当前项上面和下面的项数
    wv_R.setItems(dataList_R);// 设置数据源
    wv_R.setSeletion(3);// 默认初始选中第三项
    wv_R.setOnWheelViewListener(rightListener);

// 显示对话框，点击确认后将所选项的值显示到Button上
    new AlertDialog.Builder(this.getActivity())
            .setView(outerView)
            .setPositiveButton("确认",
                    new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialogInterface, int i) {
                            String text = selectText_left + "." + selectText_right;
                            infoBtn.setText(text);
                            infoBtn.setTextColor(green);
                        }
                    })
            .setNegativeButton("取消",null)
            .show();
}
{% endcodeblock %}

## 最后

以上，就实现了一个基本的单/双滑动标尺啦，虽然基本上放的都是代码= =不过注释写的算挺清楚的了，还有不清楚的可以留言呀~












