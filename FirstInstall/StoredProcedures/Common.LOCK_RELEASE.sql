USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Common].[LOCK_RELEASE]
	@docid	VARCHAR(MAX),
	@dataid	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	DELETE
	FROM Common.Locks
	WHERE LC_ID_DATA = @dataid
		AND LC_RECORD IN
		(
			SELECT	ID
			FROM	Common.TableFromList(@docid, ',')
		)
END
GRANT EXECUTE ON [Common].[LOCK_RELEASE] TO public;
GO