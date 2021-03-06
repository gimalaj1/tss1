﻿//Возвращает Партию указанного документа и товара
Функция НайтиПартию(Номенклатура, Документ) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	Партии.Ссылка
	|ИЗ
	|	Справочник.Партии КАК Партии
	|ГДЕ
	|	Партии.ПометкаУдаления = ЛОЖЬ
	|	И Партии.Владелец = &Владелец
	|	И Партии.ПриходныйДокумент = &ПриходныйДокумент";		
	Запрос.УстановитьПараметр("Владелец", Номенклатура);
	Запрос.УстановитьПараметр("ПриходныйДокумент", Документ);	
	
	Возврат Запрос.Выполнить().Выгрузить();
	
КонецФункции

//Возвращает ТЗ Партий по отбору. Если Партия не выбрана то представляет ТЗ всех партий с остатками
Функция ПолучитьСписокОстатковПартий(Номенклатура,Дата,Склад,Организация,Партия) Экспорт 
	
	Дата = ОснПроцедурыИФ.ПолучитьСтруктуруКонтоляОстатков(Организация,Дата).ДатаОстатков;
	
	Если ЗначениеЗаполнено(Партия) Тогда
		
		Запрос = Новый Запрос;
		Запрос.Текст = 
		"ВЫБРАТЬ
		|	ПартииТоваровОстатки.Партия КАК Партия,
		|	ПартииТоваровОстатки.СуммаОстаток,
		|	ПартииТоваровОстатки.КоличествоОстаток КАК КоличествоОстаток
		|ИЗ
		|	РегистрНакопления.ПартииТоваров.Остатки(
		|			&Дата,
		|			Организация = &Организация
		|				И Номенклатура = &Номенклатура
		|				И Склад = &Склад
		|				И Партия = &Партия) КАК ПартииТоваровОстатки
		|
		|УПОРЯДОЧИТЬ ПО
		|	КоличествоОстаток
		|АВТОУПОРЯДОЧИВАНИЕ";	
		Запрос.УстановитьПараметр("Партия", Партия);
		
	Иначе
		
		Запрос = Новый Запрос;
		Запрос.Текст = 
		"ВЫБРАТЬ
		|	ПартииТоваровОстатки.Партия КАК Партия,
		|	ПартииТоваровОстатки.СуммаОстаток,
		|	ПартииТоваровОстатки.КоличествоОстаток КАК КоличествоОстаток
		|ИЗ
		|	РегистрНакопления.ПартииТоваров.Остатки(
		|			&Дата,
		|			Организация = &Организация
		|				И Склад = &Склад
		|				И Номенклатура = &Номенклатура) КАК ПартииТоваровОстатки
		|
		|УПОРЯДОЧИТЬ ПО
		|	КоличествоОстаток
		|АВТОУПОРЯДОЧИВАНИЕ"; 		
	КонецЕсли;
	
	Запрос.УстановитьПараметр("Дата", Дата+1);
	Запрос.УстановитьПараметр("Номенклатура", Номенклатура);
	Запрос.УстановитьПараметр("Организация", Организация);
	Запрос.УстановитьПараметр("Склад", Склад);
	
	ТЗ = Запрос.Выполнить().Выгрузить();
	
	Возврат ТЗ;
	
КонецФункции

//Возвращает структуру Остаток и ДатуОстатка
Функция ПолучитьОстатокНаДату(Номенклатура,Организация,Склад,Ключ,ДатаОстатка) Экспорт
	
	С = Новый Структура;
	
	Если Организация <> Неопределено Тогда
		СтруктураКонтроляОстатков 	= ОснПроцедурыИФ.ПолучитьСтруктуруКонтоляОстатков(Организация,ДатаОстатка);
		ДатаОстатка 				= СтруктураКонтроляОстатков.ДатаОстатков;
		ВидКонтроляОстатков 		= СтруктураКонтроляОстатков.ВидКонтроляОстатков; 
	Иначе
		ВидКонтроляОстатков 		= Неопределено;
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Если Организация <> Неопределено и Склад <> Неопределено Тогда //Если выбрана Организация и Склад
		Запрос.Текст =                                             //тогда остатки на дату контроля остатков и на конец всего периода
		"ВЫБРАТЬ
		|	ПартииТоваровОстатки.КоличествоОстаток,
		|	ПартииТоваровОстаткиНаКонецВсегоПериода.КоличествоОстаток КАК ОстатокНаКонецВсегоПериода
		|ИЗ
		|	РегистрНакопления.ПартииТоваров.Остатки(
		|			&ПериодОстатка,
		|			Организация = &Организация
		|				И Склад = &Склад
		|				И Номенклатура = &Номенклатура
		|				И Партия = &Партия) КАК ПартииТоваровОстатки,
		|	РегистрНакопления.ПартииТоваров.Остатки(
		|			&ДатаОстаткаНаКонецВсегоПериода,
		|			Организация = &Организация
		|				И Склад = &Склад
		|				И Партия = &Партия
		|				И Номенклатура = &Номенклатура) КАК ПартииТоваровОстаткиНаКонецВсегоПериода";		
	Иначе //Если Организация или Склад не выбраны то остатки не фильтруются по организации и складу		
		Запрос.Текст = 
		"ВЫБРАТЬ
		|	ПартииТоваровОстатки.КоличествоОстаток,
		|	ПартииТоваровОстаткиНаКонецВсегоПериода.КоличествоОстаток КАК ОстатокНаКонецВсегоПериода
		|ИЗ
		|	РегистрНакопления.ПартииТоваров.Остатки(
		|			&ПериодОстатка,
		|				Номенклатура = &Номенклатура
		|				И Партия = &Партия) КАК ПартииТоваровОстатки,
		|	РегистрНакопления.ПартииТоваров.Остатки(
		|			&ДатаОстаткаНаКонецВсегоПериода,
		|				Партия = &Партия
		|				И Номенклатура = &Номенклатура) КАК ПартииТоваровОстаткиНаКонецВсегоПериода"; 		
	КонецЕсли;
	
	Запрос.УстановитьПараметр("Номенклатура", Номенклатура);
	Запрос.УстановитьПараметр("Склад", Склад);
	Запрос.УстановитьПараметр("Организация", Организация);
	Запрос.УстановитьПараметр("Партия", Ключ);
	Запрос.УстановитьПараметр("ПериодОстатка", ДатаОстатка);
	Запрос.УстановитьПараметр("ДатаОстаткаНаКонецВсегоПериода", КонецМесяца(ТекущаяДата()));
	
	РезультатЗапроса = Запрос.Выполнить().Выгрузить();
	
	Если РезультатЗапроса.Количество() > 1 Тогда
		Сообщить("Обнаружено " +РезультатЗапроса.Количество()+ " строк остатков!");
	КонецЕсли;
	
	С.Вставить("Остаток",РезультатЗапроса[0].КоличествоОстаток);
	С.Вставить("ДатаОстатка",ДатаОстатка);
	С.Вставить("ВидКонтроляОстатков",ВидКонтроляОстатков);
	С.Вставить("ОстатокНаКонецВсегоПериода",РезультатЗапроса[0].ОстатокНаКонецВсегоПериода);
	
	Возврат С;
	
КонецФункции

//Пометка на удаление всех партий этого приходного документа
Процедура УдалениеИлиОтменаУделенияПартийДокумента(Ссылка,ПометкаУдаления) Экспорт	
	
	Если ПометкаУдаления Тогда
		Запрос = Новый Запрос;
		Запрос.Текст = 
		"ВЫБРАТЬ
		|	Партии.Ссылка
		|ИЗ
		|	Справочник.Партии КАК Партии
		|ГДЕ
		|	Партии.ПометкаУдаления = ЛОЖЬ
		|	И Партии.ПриходныйДокумент = &ПриходныйДокумент";	
		Запрос.УстановитьПараметр("ПриходныйДокумент", Ссылка);
		РезультатЗапроса = Запрос.Выполнить();	
		ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();	
		Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
			П = ВыборкаДетальныеЗаписи.Ссылка.ПолучитьОбъект();
			П.УстановитьПометкуУдаления(Истина);
		КонецЦикла;
	Иначе
		Для Каждого Стр из Ссылка.Товары Цикл
			Если Стр.Партия.ПометкаУдаления Тогда
				П = Стр.Партия.ПолучитьОбъект();
				П.УстановитьПометкуУдаления(Ложь);	
			КонецЕсли; 			
		КонецЦикла;		
	КонецЕсли;      
	
КонецПроцедуры

//Выбрать все ЭлементыСпрПартии по этому док и те которых нет в ТаблицеТоваров пометить на удаление и очистить данные акромя ПрихДок
Процедура УдалитьПартииНеучаствующиеВДокументе(Ссылка)	
	   
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	Партии.Ссылка
	|ИЗ
	|	Справочник.Партии КАК Партии
	|ГДЕ
	|	Партии.ПометкаУдаления = ЛОЖЬ
	|	И Партии.ПриходныйДокумент = &ПриходныйДокумент";	
	Запрос.УстановитьПараметр("ПриходныйДокумент", Ссылка);
	РезультатЗапроса = Запрос.Выполнить();	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		
		Найдена = Ложь;
		Для Каждого Стр из Ссылка.Товары Цикл
			
			Если Стр.Партия = ВыборкаДетальныеЗаписи.Ссылка Тогда
				Найдена = Истина;
			КонецЕсли;
			
		КонецЦикла;
		
		Если НЕ Найдена Тогда
			П = ВыборкаДетальныеЗаписи.Ссылка.ПолучитьОбъект();
			П.УстановитьПометкуУдаления(Истина);
		КонецЕсли;   		
	КонецЦикла;  
КонецПроцедуры

//Создание новой Партии при изменении Номенклатуры в документентах поступлений
Функция СоздатьНовуюПартию(Номенклатура) Экспорт 
	
	НоваяПартия = СоздатьЭлемент();
	НоваяПартия.Владелец = Номенклатура;
	НоваяПартия.Записать();
	
	Возврат НоваяПартия;
	
КонецФункции 

//Дополняет ранее созданную Партию данными из документа при проведении
Процедура ОбновитьПартию(Ссылка,Отказ) Экспорт 
	
	УдалитьПартииНеучаствующиеВДокументе(Ссылка);
	
	Для Каждого ТекСтрокаТовары Из Ссылка.Товары Цикл
		   		
		СуммаСебестоимость 		= ТекСтрокаТовары.Сумма;
		КоличествоСебестоимость = ТекСтрокаТовары.Количество;
		
		Если ТекСтрокаТовары.Партия.ЗакупочнаяСумма <> СуммаСебестоимость 
			или ТекСтрокаТовары.Партия.ЗакупочноеКоличество <> КоличествоСебестоимость 
			или ТекСтрокаТовары.Партия.ПриходныйДокумент <> Ссылка Тогда
			
			ПартияСсылка = ТекСтрокаТовары.Партия.ПолучитьОбъект();
			ПартияСсылка.ЗакупочнаяЦена 		= СуммаСебестоимость/КоличествоСебестоимость;
			ПартияСсылка.ЗакупочнаяСумма		= СуммаСебестоимость;
			ПартияСсылка.ЗакупочноеКоличество 	= КоличествоСебестоимость;
			ПартияСсылка.ПриходныйДокумент 		= Ссылка;		
			
			Попытка
				ПартияСсылка.Записать();			
			Исключение
				Сообщить("Не изменена партия по отбору: " +ТекСтрокаТовары.Номенклатура+ " , " +Ссылка+ " "+ ОписаниеОшибки());
				Отказ = Истина;
			КонецПопытки;
		КонецЕсли;
		
		Если ТекСтрокаТовары.Партия.ПометкаУдаления Тогда
			ТекСтрокаТовары.Партия.ПолучитьОбъект().УстановитьПометкуУдаления(Ложь);
		КонецЕсли;
		
	КонецЦикла; 	
КонецПроцедуры  