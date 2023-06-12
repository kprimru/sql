﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Book].[BookDeliveryLast]', 'V ') IS NULL EXEC('CREATE VIEW [Book].[BookDeliveryLast]  AS SELECT 1')
GO
ALTER VIEW [Book].[BookDeliveryLast]
--WITH SCHEMABINDING
AS
	SELECT
		BD_ID_MASTER, BD_ID, 
		BD_PRICE, BD_COUNT,
		BD_DATE, BD_END
	FROM
		Book.BookDeliveryAll a
	WHERE BD_REF IN (1, 3)GO
