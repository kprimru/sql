USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Reg].[RegHistoryOperationDetailView]', 'V ') IS NULL EXEC('CREATE VIEW [Reg].[RegHistoryOperationDetailView]  AS SELECT 1')
GO

CREATE OR ALTER VIEW [Reg].[RegHistoryOperationDetailView]
AS
	SELECT
		src.ID_DISTR, src.DATE, dst.ID,
		C.Type, c.Value
	FROM Reg.RegHistoryView AS SRC WITH(NOEXPAND)
	CROSS APPLY
    (
		SELECT TOP (1)
			ID,	ID_DISTR, DATE,
			SystemShortName, NT_SHORT, SST_SHORT,
			SUBHOST, TRAN_COUNT, TRAN_LEFT,
			DS_NAME, DS_REG, REG_DATE, FIRST_REG, COMPLECT, COMMENT
		FROM
			Reg.RegHistoryView AS DST WITH(NOEXPAND)
	    WHERE src.ID_DISTR = dst.ID_DISTR
	        AND DST.DATE > SRC.DATE
	    ORDER BY DST.DATE
	) AS dst
	CROSS APPLY
	(
		SELECT
			[Type]		= 'Система',
			[Value]		= 'с ' + src.SystemShortName + ' на ' + dst.SystemShortName
		WHERE src.SystemShortName <> dst.SystemShortName
		---
		UNION ALL
		---
		SELECT
			[Type]		= 'Сетевитость',
			[Value]		= 'с ' + src.NT_SHORT + ' на ' + dst.NT_SHORT
		WHERE src.NT_SHORT <> dst.NT_SHORT
		---
		UNION ALL
		---
		SELECT
			[Type]		= 'Тип системы',
			[Value]		= 'с ' + src.SST_SHORT + ' на ' + dst.SST_SHORT
		WHERE src.SST_SHORT <> dst.SST_SHORT
		---
		UNION ALL
		---
		SELECT
			[Type]		= 'Признак подхоста',
			[Value]		= 'с ' + CASE WHEN src.SUBHOST = 1 THEN 'Да' ELSE 'Нет' END + ' на ' + CASE WHEN dst.SUBHOST = 1 THEN 'Да' ELSE 'Нет' END
		WHERE src.SUBHOST <> dst.SUBHOST
		---
		UNION ALL
		---
		SELECT
			[Type]		= 'Кол-во переносов',
			[Value]		= 'с ' + Cast(src.TRAN_COUNT AS VarChar(10)) + ' на ' + Cast(dst.TRAN_COUNT AS VarChar(10))
		WHERE src.TRAN_COUNT <> dst.TRAN_COUNT
		---
		UNION ALL
		---
		SELECT
			[Type]		= 'Осталось счетчиков',
			[Value]		= 'с ' + Cast(src.TRAN_LEFT AS VarChar(10)) + ' на ' + Cast(dst.TRAN_LEFT AS VarChar(10))
		WHERE src.TRAN_LEFT <> dst.TRAN_LEFT
		---
		UNION ALL
		---
		SELECT
			[Type]		= 'Статус',
			[Value]		= 'с ' + src.DS_NAME + ' на ' + dst.DS_NAME
		WHERE src.DS_NAME <> dst.DS_NAME
		---
		UNION ALL
		---
		SELECT
			[Type]		= 'Дата регистрации',
			[Value]		= 'с ' + Convert(VarChar(20), src.REG_DATE, 104) + ' на ' + Convert(VarChar(20), dst.REG_DATE, 104)
		WHERE IsNull(src.REG_DATE, '1900-01-01') <> IsNull(dst.REG_DATE, '1900-01-01')
		---
		UNION ALL
		---
		SELECT
			[Type]		= 'Дата первой регистрации',
			[Value]		= 'с ' + IsNull(Convert(VarChar(20), src.FIRST_REG, 104), '-') + ' на ' + IsNull(Convert(VarChar(20), dst.FIRST_REG, 104), '-')
		WHERE IsNull(src.FIRST_REG, '1900-01-01') <> IsNull(dst.FIRST_REG, '1900-01-01')
		---
		UNION ALL
		---
		SELECT
			[Type]		= 'Комплект',
			[Value]		= 'с ' + ISNULL(src.COMPLECT, '') + ' на ' + ISNULL(dst.COMPLECT, '')
		WHERE ISNULL(src.COMPLECT, '') <> ISNULL(dst.COMPLECT, '')
		---
		UNION ALL
		---
		SELECT
			[Type]		= 'Примечание',
			[Value]		= 'с ' + ISNULL(src.COMMENT, '') + ' на ' + ISNULL(dst.COMMENT, '')
		WHERE ISNULL(src.COMMENT, '') <> ISNULL(dst.COMMENT, '')
	) AS C
GO
