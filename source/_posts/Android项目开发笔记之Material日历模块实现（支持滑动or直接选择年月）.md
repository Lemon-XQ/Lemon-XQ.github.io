---
title: Android项目开发笔记之Material日历模块实现（支持滑动/直接选择年月）
date: 2018-03-11 00:26:38
categories:
- Android
tags:
- CalendarView
- Material
---
## 写在前面
　　本系列第二篇（隔了好久的感觉orz）。本篇主要讲的是很多App里都会有的日历模块实现，基于[Github上一个优秀的开源项目](https://github.com/huanghaibin-dev/CalendarView)进行了扩展，支持滑动切换月份以及下拉直接选择年月~
<!--more-->
## 实现效果

先放一下实现的效果图：
![](http://okwl1c157.bkt.clouddn.com/android-calendar1.jpg)


![](http://okwl1c157.bkt.clouddn.com/android-calendar2.jpg)

## 引入插件

- 在app/build.gradle的dependencies中增加：
`compile 'com.haibin:calendarview:3.2.0'`
- 重新sync

## 定义布局

{% codeblock lang:xml %}
<com.haibin.calendarview.CalendarView
    android:id="@+id/history_calendarView"
    android:layout_width="match_parent"
    android:layout_height="0dp"
    android:layout_weight="5"
    android:background="@color/colorPrimary"
    app:month_view="你的包名.CustomMonthView"
    app:week_bar_view="你的包名.EnglishWeekbar"
    app:week_line_background="@color/white"
    app:calendar_height="37dp"
    app:current_day_text_color="#d94373"
    app:selected_theme_color="@color/white"
    app:lunar_text_size="0sp"
    app:min_year="2018"
    app:max_year="2050"
    app:month_view_show_mode="mode_all"
    app:other_month_text_color="#82ffffff"
     />
{% endcodeblock %}


## 自定义MonthView(选中日期时效果 & 特殊事件效果)
- 新建CustomMonthView.java,代码如下：
{% codeblock lang:java %}
public class CustomMonthView extends MonthView {
    private int mRadius;

    public CustomMonthView(Context context) {
        super(context);
        mSchemePaint.setColor(Color.WHITE);
        mSchemeTextPaint.setColor(Color.GREEN);
    }

    @Override
    protected void onPreviewHook() {
        mRadius = Math.min(mItemWidth, mItemHeight) / 5 * 2;
        mCurMonthTextPaint.setColor(Color.WHITE);// 白色圆圈
        mSchemePaint.setStyle(Paint.Style.FILL);
        mSelectTextPaint.setColor(getResources().getColor(R.color.colorPrimary));
        setLayerType( LAYER_TYPE_SOFTWARE , null);
    }

    @Override
    protected void onLoopStart(int x, int y) {

    }

    @Override
    protected boolean onDrawSelected(Canvas canvas, Calendar calendar, int x, int y, boolean hasScheme) {
		// 画白色圆圈
        int cx = x + mItemWidth / 2;
        int cy = y + mItemHeight / 2;
        canvas.drawCircle(cx, cy, mRadius, mSelectedPaint);
        return false;
    }

    @Override
    protected void onDrawScheme(Canvas canvas, Calendar calendar, int x, int y) {
		// 画右上角白点，表示特殊日期
        int cx = x + 4*mItemWidth / 5;
        int cy = y + mItemHeight / 5;
        canvas.drawCircle(cx, cy, mRadius/4, mSchemePaint);
    }

    @Override
    protected void onDrawText(Canvas canvas, Calendar calendar, int x, int y, boolean hasScheme, boolean isSelected) {
        float baselineY = mTextBaseLine + y;
        int cx = x + mItemWidth / 2;
        if (isSelected) {
            canvas.drawText(String.valueOf(calendar.getDay()),
                    cx,
                    baselineY,
                    mSelectTextPaint);
        }else if (hasScheme) {
            canvas.drawText(String.valueOf(calendar.getDay()),
                    cx,
                    baselineY,
                    calendar.isCurrentDay() ? mCurDayTextPaint :
                            calendar.isCurrentMonth() ? mSchemeTextPaint : mOtherMonthTextPaint);

        } else {
            canvas.drawText(String.valueOf(calendar.getDay()), cx, baselineY,
                    calendar.isCurrentDay() ? mCurDayTextPaint :
                            calendar.isCurrentMonth() ? mCurMonthTextPaint : mOtherMonthTextPaint);
        }
    }
}
{% endcodeblock %}

## 自定义WeekBar（英文版）
默认Weekbar是中文的，个人觉得英文的看起来比较舒服，所以自定义了一个，步骤如下：

1. 新建english_weekbar.xml，内容是7个TextView,代表周一到周日，代码比较简单就不贴了
2. 新建EnglishWeekbar.java,加载english_weekbar.xml布局,代码如下：
{% codeblock lang:java %}
public class EnglishWeekbar extends WeekBar {
    public EnglishWeekbar(Context context) {
        super(context);
        LayoutInflater.from(context).inflate(R.layout.english_week_bar, this, true);
    }
}
{% endcodeblock %}

## 制作下拉选择控件（使用Spinner）
同样介绍一个github上的[项目](https://github.com/jaredrummler/MaterialSpinner)，可定制项比较丰富，且有Material效果。

- 引入：`implementation 'com.jaredrummler:material-spinner:1.2.4@aar'`
- xml中使用：
{% codeblock lang:xml %}
   <com.jaredrummler.materialspinner.MaterialSpinner
        android:id="@+id/dateSpinner"
        android:layout_width="150dp"
        android:layout_height="wrap_content"
        android:layout_gravity="center_horizontal"
        android:layout_marginStart="85dp"
        app:ms_background_color="@color/colorPrimary"
        app:ms_background_selector="@color/colorPrimary"
        app:ms_arrow_tint="@color/white"
        app:ms_dropdown_height="250dp"
        app:ms_hint_color="@color/black"
        app:ms_text_color="@color/white"
        android:textSize="18sp" />
{% endcodeblock %}
- activity中往Spinner填充日期数据（范围为2018年-2050年）
{% codeblock lang:java %}
    private int currentIndex;
    void initData(){
        currentIndex = 1;
        int cur_year = Util.getYear(new Date());
        int cur_month = Util.getMonth(new Date());

        List<String> dateList = new ArrayList<>();
        for(int year=2018; year<=2050; year++){
            for(int month=1;month<=12;month++){
                dateList.add(year+"-"+month);
                if(year <= cur_year && month < cur_month) currentIndex++;
            }
        }
        dateSpinner.setItems(dateList);// 填充数据
        dateSpinner.setSelectedIndex(currentIndex);// 默认选中当前月
    }
{% endcodeblock %}
- 
## 控件组合
　　不难发现，上面定义的这两个控件其实是没有关系的，那么怎么实现滑动切换的时候，Spinner显示的日期也会改变，而下拉选择某月后，CalendarView又会滑动到目标月份呢？其实也不难，只需要监听二者相应的事件，再进行处理即可，具体步骤如下：
1. 监听calendarView的onMonthChanged事件
{% codeblock lang:java %}
    // 滑动日历时更改Title显示,根据与当前月份的偏移量计算目标月份在Spinner中的索引值
    calendarView.setOnMonthChangeListener(new CalendarView.OnMonthChangeListener() {
        @Override
        public void onMonthChange(int year, int month) {
            int cur_month = calendarView.getCurMonth();
            int cur_year = calendarView.getCurYear();
            int offset;
            if(cur_year == year){
                offset = month - cur_month;
            }else{
                offset = (year - cur_year)*12 + month - cur_month;
            }
            dateSpinner.setSelectedIndex(currentIndex + offset);
        }
    });
{% endcodeblock %}
2. 监听dateSpinner的onItemSelected事件
{% codeblock lang:java %}
    // 年月选择监听,提取点击项的年份及月份，滑动日历至目标月份
    dateSpinner.setOnItemSelectedListener(new MaterialSpinner.OnItemSelectedListener<String>() {
        @Override
        public void onItemSelected(MaterialSpinner view, int position, long id, String item) {
            String[] dateStr = item.split("-");
            int year = Integer.parseInt(dateStr[0]);
            int month = Integer.parseInt(dateStr[1]);
            calendarView.scrollToCalendar(year,month,1);
        }
    });
{% endcodeblock %}

## 其他
1. 使用calendarView.setSchemeDate(dateList)可以设置特殊日期
2. com.haibin.calendarview中也有一个Calendar类，不要和java.util.Calendar混了，特别在进行java.util.Date和calendar的转换时需要注意。