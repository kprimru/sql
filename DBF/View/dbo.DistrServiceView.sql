﻿USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[DistrServiceView]', 'V ') IS NULL EXEC('CREATE VIEW [dbo].[DistrServiceView]  AS SELECT 1')
GO
ALTER VIEW [dbo].[DistrServiceView]
AS
SELECT
	DIS_ID, DIS_NUM, DIS_COMP_NUM, DIS_STR,
	SYS_ORDER, SYS_REG_NAME, RN_SERVICE,
	CASE RN_SERVICE
		WHEN 0 THEN 'Включен'
		WHEN 1 THEN 'Отключен'
		WHEN 2 THEN 'Недействующий'
		ELSE 'Отсутсвует на РЦ'
	END AS DIS_SERVICE
FROM
	dbo.DistrView WITH(NOEXPAND) LEFT OUTER JOIN
	dbo.RegNodeTable ON RN_DISTR_NUM = DIS_NUM
				AND RN_COMP_NUM = DIS_COMP_NUM
				AND RN_SYS_NAME = SYS_REG_NAME
GO
