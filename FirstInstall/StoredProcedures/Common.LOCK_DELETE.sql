USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Common].[LOCK_DELETE]
	@ID	VARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	DELETE 
	FROM Common.Locks
	WHERE LC_ID IN
		(
			SELECT ID
			FROM Common.TableFromList(@ID, ',')
		)
END
