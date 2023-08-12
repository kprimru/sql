USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Reg].[RegHistoryOperationView]', 'V ') IS NULL EXEC('CREATE VIEW [Reg].[RegHistoryOperationView]  AS SELECT 1')
GO
CREATE OR ALTER VIEW [Reg].[RegHistoryOperationView]
AS
	SELECT
		src.ID_DISTR, dst.ID, dst.DATE,
		CASE
			WHEN src.SystemShortName <> dst.SystemShortName THEN 'Система. '
			ELSE ''
		END +
		CASE
			WHEN src.NT_SHORT <> dst.NT_SHORT THEN 'Сетевитость. '
			ELSE ''
		END +
		CASE
			WHEN src.SST_SHORT <> dst.SST_SHORT THEN 'Тип системы. '
			ELSE ''
		END +
		CASE
			WHEN src.SUBHOST <> dst.SUBHOST THEN 'Признак подхоста. '
			ELSE ''
		END +
		CASE
			WHEN src.TRAN_COUNT <> dst.TRAN_COUNT THEN 'Перенос. '
			ELSE ''
		END +
		CASE
			WHEN src.TRAN_LEFT <> dst.TRAN_LEFT THEN 'Осталось счетчиков. '
			ELSE ''
		END +
		CASE
			WHEN src.DS_NAME <> dst.DS_NAME THEN
				CASE dst.DS_REG
					WHEN 0 THEN 'Включение. '
					WHEN 1 THEN 'Отключение. '
					WHEN 2 THEN 'Удаление. '
					ELSE 'Статус: с ' + src.DS_NAME + ' на ' + dst.DS_NAME
				END
			ELSE ''
		END +
		CASE
			WHEN ISNULL(src.REG_DATE, GETDATE()) <> ISNULL(dst.REG_DATE, GETDATE()) THEN 'Регистрация. '
			ELSE ''
		END +
		CASE
			WHEN ISNULL(src.FIRST_REG, GETDATE()) <> ISNULL(dst.FIRST_REG, GETDATE()) THEN 'Дата первой регистрации. '
			ELSE ''
		END +
		CASE
			WHEN ISNULL(src.COMPLECT, '') <> ISNULL(dst.COMPLECT, '') THEN 'Смена комплекта. '
			ELSE ''
		END +
		CASE
			WHEN ISNULL(src.COMMENT, '') <> ISNULL(dst.COMMENT, '') THEN 'Смена примечания. '
			ELSE ''
		END	AS CHANGES
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
GO
