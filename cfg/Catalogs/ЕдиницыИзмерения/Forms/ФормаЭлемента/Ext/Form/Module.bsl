﻿
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Элементы.Коэффициент.Видимость = ЗначениеЗаполнено(Объект.БазоваяЕдиницаИзмерения);
КонецПроцедуры

&НаКлиенте
Процедура НаименованиеПриИзменении(Элемент)
	Элементы.Коэффициент.Видимость = ЗначениеЗаполнено(Объект.БазоваяЕдиницаИзмерения);
КонецПроцедуры
