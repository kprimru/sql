﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Book].[BOOK_DELIVERY_SELECT]
	@RC	INT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	SELECT	*
	FROM	[Book].[BookDeliveryActive]

	SELECT	@RC = @@ROWCOUNT
END
GO
