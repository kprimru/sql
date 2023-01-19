﻿USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[PriceDependView]', 'V ') IS NULL EXEC('CREATE VIEW [dbo].[PriceDependView]  AS SELECT 1')
GO
ALTER VIEW [dbo].[PriceDependView]
AS
	SELECT PD_ID, PD_ID_TYPE, PT_NAME, PD_ID_PERIOD, PD_COEF
	FROM
		dbo.PriceDepend
		INNER JOIN dbo.PriceTypeTable ON PT_ID = PD_ID_SOURCEGO
