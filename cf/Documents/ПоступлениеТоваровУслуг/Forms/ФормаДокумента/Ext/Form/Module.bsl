﻿
&НаКлиенте
Процедура ТоварыЦенаПриИзменении(Элемент)
	
	ТекДанные = Элементы.Товары.ТекущиеДанные;
	ТекДанные.Сумма = ТекДанные.Количество * ТекДанные.Цена;
	
	Если Объект.УчитыватьНДС Тогда
		ТекДанные.СуммаНДС 		= ТекДанные.Сумма / 18;//ТекДанные.СтавкаНДС;
		ТекДанные.СуммаБезНДС 	= ТекДанные.Количество * ТекДанные.Цена;		
	КонецЕсли;
	
	Объект.СуммаНДС 	= Объект.Товары.Итог("СуммаНДС");
	Объект.СуммаБезНДС 	= Объект.Товары.Итог("СуммаБезНДС");	
	Объект.СуммаДокумента = Объект.Товары.Итог("Сумма");
	
КонецПроцедуры

&НаКлиенте
Процедура ТоварыСуммаПриИзменении(Элемент)
	Элементы.Товары.ТекущиеДанные.Цена = Элементы.Товары.ТекущиеДанные.Сумма / Элементы.Товары.ТекущиеДанные.Количество;
	Объект.СуммаДокумента = Объект.Товары.Итог("Сумма");
КонецПроцедуры


&НаКлиенте
Процедура ТоварыПриНачалеРедактирования(Элемент, НоваяСтрока, Копирование)
	
	Если Копирование Тогда
		Элемент.ТекущиеДанные.Партия = Неопределено;
		ТоварыНоменклатураПриИзмененииНаСервере(Элемент.ТекущиеДанные.НомерСтроки);	
	КонецЕсли;	
	
	Если Элемент.ТекущийЭлемент.Заголовок = "Партия" Тогда
		ТоварыПартияОткрытие(Элемент, Ложь)
	КонецЕсли;
		
КонецПроцедуры
&НаКлиенте
Функция СформироватьПараметрыФормы(ТекСтр)
	
	ЗначенияОтборов = Новый Структура;
	ЗначенияОтборов.Вставить("Владелец", ТекСтр.Номенклатура);
	ЗначенияОтборов.Вставить("Организация", Объект.Организация);
	ЗначенияОтборов.Вставить("Склад", Объект.Склад);	
	ЗначенияОтборов.Вставить("ДатаОстатков",Объект.Дата);
	
	ПараметрыФормы = Новый Структура("Ключ", ТекСтр.Партия);
	ПараметрыФормы.Вставить("Отбор", ЗначенияОтборов);

	Возврат ПараметрыФормы;
	
КонецФункции 
&НаКлиенте
Процедура ДвиженияПартииТоваровПартияОткрытие(Элемент, СтандартнаяОбработка)  	
	СтандартнаяОбработка = Ложь;	
	ПараметрыФормы = СформироватьПараметрыФормы(Элементы.ДвиженияПартииТоваров.ТекущиеДанные);
	ОткрытьФорму("Справочник.Партии.Форма.ФормаЭлементаОткрыть", ПараметрыФормы, Элемент);	
КонецПроцедуры
&НаКлиенте
Процедура ТоварыПартияОткрытие(Элемент, СтандартнаяОбработка)  	
	СтандартнаяОбработка = Ложь;	
	ПараметрыФормы = СформироватьПараметрыФормы(Элементы.Товары.ТекущиеДанные);
	ОткрытьФорму("Справочник.Партии.Форма.ФормаЭлементаОткрыть", ПараметрыФормы, Элемент);	
КонецПроцедуры


&НаКлиенте
Процедура ТоварыНоменклатураПриИзменении(Элемент)	
	ТоварыНоменклатураПриИзмененииНаСервере(Элементы.Товары.ТекущиеДанные.НомерСтроки);	
КонецПроцедуры
&НаСервере
Процедура ТоварыНоменклатураПриИзмененииНаСервере(НомерСтроки)
	
	ДанныеСтроки = Объект.Товары[НомерСтроки-1];
	
	Если ЗначениеЗаполнено(ДанныеСтроки.Партия) Тогда
		ДанныеСтроки.Партия.ПолучитьОбъект().УстановитьПометкуУдаления(Истина);
		ДанныеСтроки.Партия = Неопределено;
	КонецЕсли;

	Если ЗначениеЗаполнено(ДанныеСтроки.Номенклатура) Тогда
		ДанныеСтроки.Партия = Справочники.Партии.СоздатьНовуюПартию(ДанныеСтроки.Номенклатура).Ссылка;
		ДанныеСтроки.ЕдиницаИзмерения = ДанныеСтроки.Номенклатура.ЕдиницаИзмерения;
	КонецЕсли;
	
КонецПроцедуры


&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	 ОбновитьВидимостьЭлементов();		
КонецПроцедуры

&НаКлиенте
Процедура УчитыватьНДСПриИзменении(Элемент)
	
	Если Объект.УчитыватьНДС Тогда
		//Вопрос
		//Пересчитать подвал
		//Пересчитать таблицу товаров
	Иначе
		//Вопрос
		//Пересчитать подвал
		//Пересчитать таблицу товаров
	КонецЕсли;
	
	ОбновитьВидимостьЭлементов();
КонецПроцедуры

&НаСервере
Процедура ОбновитьВидимостьЭлементов()
	
	Если Объект.УчитыватьНДС Тогда
		Элементы.СуммаБезНДС.Видимость 			= Истина;
		Элементы.СуммаНДС.Видимость 			= Истина;
		Элементы.ТоварыСуммаБезНДС.Видимость 	= Истина;
		Элементы.ТоварыСуммаНДС.Видимость 		= Истина;
		Элементы.ТоварыСтавкаНДС.Видимость 		= Истина;
	Иначе
		Элементы.СуммаБезНДС.Видимость 			= Ложь;
		Элементы.СуммаНДС.Видимость 			= Ложь;
		Элементы.ТоварыСуммаБезНДС.Видимость 	= Ложь;
		Элементы.ТоварыСуммаНДС.Видимость 		= Ложь;
		Элементы.ТоварыСтавкаНДС.Видимость 		= Ложь;
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура СуммаВклНДСПриИзменении(Элемент)
	
	Если Объект.СуммаВклНДС Тогда
		Объект.УчитыватьНДС = Истина;
	КонецЕсли;
	
	ОбновитьВидимостьЭлементов();
	
КонецПроцедуры
