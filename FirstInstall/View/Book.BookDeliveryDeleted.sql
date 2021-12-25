﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [Book].[BookDeliveryDeleted]
--WITH SCHEMABINDING
AS
	SELECT
		BD_ID_MASTER, BD_ID, 
		BD_PRICE, BD_COUNT,
		BD_DATE, BD_END
	FROM
		Book.BookDeliveryAll a
	WHERE BD_REF = 3GO
