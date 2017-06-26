﻿
Процедура ОбработкаПроведения(Отказ, Режим)
	
	//Свернем все товары чтобы избежать задвоенных строк
	ТЗТоваров = Товары.Выгрузить(,"Партия,Номенклатура,Количество");
	ТЗТоваров.Свернуть("Партия,Номенклатура","Количество");   

	
	// регистр ПартииТоваров Расход  и Приход
	Движения.ПартииТоваров.Записывать = Истина;
	
	Для Каждого ТекСтрокаТовары Из ТЗТоваров Цикл
		
		//Список Партий с остатками в Таблицу значений
		СписокОстатковПартий = Справочники.Партии.ПолучитьСписокОстатковПартий(ТекСтрокаТовары.Номенклатура,Дата,Склад,Организация,ТекСтрокаТовары.Партия); 
		НеобходимыйОстаток   = ТекСтрокаТовары.Количество;
		
		Для Каждого СтрокаПартии из СписокОстатковПартий Цикл
			
			Если НеобходимыйОстаток = 0 Тогда
				Прервать;  //Товар распределился по партиям
			КонецЕсли;
			
			ДвижениеРасход = Движения.ПартииТоваров.Добавить();
			ДвижениеРасход.ВидДвижения 	= ВидДвиженияНакопления.Расход;
			ДвижениеРасход.Период 		= Дата;
			ДвижениеРасход.Организация 	= Организация;
			ДвижениеРасход.Склад 		= Склад;
			ДвижениеРасход.Номенклатура = ТекСтрокаТовары.Номенклатура;
			ДвижениеРасход.Партия 		= СтрокаПартии.Партия;
			
			Если НеобходимыйОстаток <= СтрокаПартии.КоличествоОстаток Тогда //ИЛИ СтрокаПартии.КоличествоОстаток < 0
				ДвижениеРасход.Количество 	= НеобходимыйОстаток;
				НеобходимыйОстаток 			= НеобходимыйОстаток - ДвижениеРасход.Количество;
				                                    				
			ИначеЕсли НеобходимыйОстаток > СтрокаПартии.КоличествоОстаток Тогда
				ДвижениеРасход.Количество 	= СтрокаПартии.КоличествоОстаток;
				НеобходимыйОстаток 			= НеобходимыйОстаток - ДвижениеРасход.Количество;
			КонецЕсли;
            ДвижениеРасход.Сумма		= СтрокаПартии.Партия.ЗакупочнаяЦена * ДвижениеРасход.Количество;
			
			ДвижениеПриход = Движения.ПартииТоваров.Добавить();
			ДвижениеПриход.ВидДвижения 	= ВидДвиженияНакопления.Приход;
			ДвижениеПриход.Период 		= Дата;
			ДвижениеПриход.Организация 	= Организация;
			ДвижениеПриход.Склад 		= СкладПолучатель;
			ДвижениеПриход.Номенклатура = ТекСтрокаТовары.Номенклатура;
			ДвижениеПриход.Партия 		= ДвижениеРасход.Партия;
			ДвижениеПриход.Количество 	= ДвижениеРасход.Количество;
			ДвижениеПриход.Сумма		= СтрокаПартии.Партия.ЗакупочнаяЦена * ДвижениеПриход.Количество;

		КонецЦикла;
		
		//Если нехватило остатков, то берем из последней партии
		Если НеобходимыйОстаток > 0 Тогда
			
			Если Организация.КонтролироватьОстатки Тогда
				Сообщить("" +Ссылка +Символы.ПС+
				"Нехватает: " +НеобходимыйОстаток+ " " +ТекСтрокаТовары.Номенклатура+ ", Склад: " +Склад+ ", Организация: " +Организация);
				Отказ = Истина;
			Иначе 				
				ДвижениеРасход.Количество 	= ДвижениеРасход.Количество + НеобходимыйОстаток;
				ДвижениеРасход.Сумма		= СтрокаПартии.Партия.ЗакупочнаяЦена * ДвижениеРасход.Количество;
				ДвижениеПриход.Количество 	= ДвижениеПриход.Количество + НеобходимыйОстаток;
				ДвижениеПриход.Сумма		= СтрокаПартии.Партия.ЗакупочнаяЦена * ДвижениеПриход.Количество;
			КонецЕсли;
			
		КонецЕсли; 		
		
	КонецЦикла;
	
КонецПроцедуры


Процедура ОбработкаЗаполнения(ДанныеЗаполнения, СтандартнаяОбработка)
	
	Если ТипЗнч(ДанныеЗаполнения) = Тип("ДокументСсылка.ПоступлениеТоваровУслуг") Тогда
		// Заполнение шапки
		Организация = ДанныеЗаполнения.Организация;
		Склад = ДанныеЗаполнения.Склад;
		Для Каждого ТекСтрокаТовары Из ДанныеЗаполнения.Товары Цикл
			НоваяСтрока = Товары.Добавить();
			НоваяСтрока.Количество 		= ТекСтрокаТовары.Количество;
			НоваяСтрока.Номенклатура 	= ТекСтрокаТовары.Номенклатура;
			НоваяСтрока.Партия 			= ТекСтрокаТовары.Партия;
		КонецЦикла;
	ИначеЕсли ТипЗнч(ДанныеЗаполнения) = Тип("ДокументСсылка.РеализацияТоваровУслуг") Тогда
		// Заполнение шапки
		Организация = ДанныеЗаполнения.Организация;
		Склад = ДанныеЗаполнения.Склад;
		Для Каждого ТекСтрокаТовары Из ДанныеЗаполнения.Товары Цикл
			НоваяСтрока = Товары.Добавить();
			НоваяСтрока.Количество 		= ТекСтрокаТовары.Количество;
			НоваяСтрока.Номенклатура 	= ТекСтрокаТовары.Номенклатура;
			НоваяСтрока.Партия 			= ТекСтрокаТовары.Партия;
		КонецЦикла;
	КонецЕсли;
	
КонецПроцедуры
