﻿
&НаКлиенте
Процедура ТоварыЦенаПриИзменении(Элемент)
	
	ТекДанные = Элементы.Товары.ТекущиеДанные;
	ТекДанные.Сумма = ТекДанные.Количество * ТекДанные.Цена;
	
КонецПроцедуры

&НаКлиенте
Процедура ТоварыСуммаПриИзменении(Элемент)
	
	ТекДанные = Элементы.Товары.ТекущиеДанные;
	
	Если ТекДанные.Количество <> 0 Тогда
		ТекДанные.Цена = ТекДанные.Сумма / ТекДанные.Количество;
	КонецЕсли;
		
КонецПроцедуры

&НаКлиенте
Процедура ТоварыНоменклатураПриИзменении(Элемент)	
	
	НомерСтроки = Элементы.Товары.ТекущиеДанные.НомерСтроки;
	ТоварыНоменклатураПриИзмененииНаСервере(НомерСтроки);	
	
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
	ЗначенияОтборов.Вставить("Владелец",     ТекСтр.Номенклатура);
	ЗначенияОтборов.Вставить("Организация",  Объект.Организация);
	ЗначенияОтборов.Вставить("Склад",        Объект.Склад);	
	ЗначенияОтборов.Вставить("ДатаОстатков", Объект.Дата);
	
	ПараметрыФормы = Новый Структура("Ключ", ТекСтр.Партия);
	ПараметрыФормы.Вставить("Отбор",         ЗначенияОтборов);

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

	Если не ЗначениеЗаполнено(Объект.Ссылка) Тогда // ЭтоНовый
		Объект.Ответственный = ПараметрыСеанса.ТекущийПользователь;
	КонецЕсли;
		
КонецПроцедуры


&НаКлиенте
Процедура ЗаполнитьПоИнвентаризации(Команда)
	
	Если не ЗначениеЗаполнено(Объект.ИнвентаризацияТМЦ) Тогда
		
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = "Не заполнен документ инвентаризации";
		Сообщение.Поле = "ИнвентаризацияТМЦ";
		Сообщение.ПутьКДанным = "Объект";
		Сообщение.Сообщить();
		
		Возврат;
		
	КонецЕсли;
	
	Если Объект.Товары.Количество() > 0 Тогда
		
		ОбработкаОтвета = Новый ОписаниеОповещения("ОбработкаОтветаПользователя", ЭтотОбъект);
		ПоказатьВопрос(ОбработкаОтвета, "Табличная часть будет очищена, продолжить?", РежимДиалогаВопрос.ДаНет);
		
	Иначе
		
		ЗаполнитьПоИнвентаризацииНаСервере();
		
	КонецЕсли;
	
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОтветаПользователя(ОтветПользователя, ДополнительныеПараметры) Экспорт
	
	Если ОтветПользователя = КодВозвратаДиалога.Да Тогда
		ЗаполнитьПоИнвентаризацииНаСервере();
	КонецЕсли;
	
КонецПроцедуры


&НаСервере
Процедура ЗаполнитьПоИнвентаризацииНаСервере()
	
	Объект.Товары.Очистить();
	
	Для каждого СтрокаТЧ из Объект.ИнвентаризацияТМЦ.Товары Цикл
		
		Если СтрокаТЧ.Количество > СтрокаТЧ.КоличествоУчет Тогда 
			
			СтрокаОприходования = Объект.Товары.Добавить();
			ЗаполнитьЗначенияСвойств(СтрокаОприходования, СтрокаТЧ);
			СтрокаОприходования.Количество = СтрокаТЧ.Количество - СтрокаТЧ.КоличествоУчет;
			СтрокаОприходования.Сумма = СтрокаОприходования.Количество * СтрокаТЧ.Цена;
			
		КонецЕсли;
		                                                                                   		
	КонецЦикла;
	
КонецПроцедуры
