﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Common].[LOCK_DELETE]
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
GO
GRANT EXECUTE ON [Common].[LOCK_DELETE] TO rl_lock_d;
GO
