﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Clients].[VENDOR_DELETED]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Clients].[VENDOR_DELETED]  AS SELECT 1')
GO
ALTER PROCEDURE [Clients].[VENDOR_DELETED]
	@RC INT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	SELECT	*
	FROM	[Clients].[VendorDeleted]

	SELECT	@RC = @@ROWCOUNT
END
GO
GRANT EXECUTE ON [Clients].[VENDOR_DELETED] TO rl_vendor_r;
GO
