USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[TableNumber]
(
	@N INT
)
RETURNS @TBL TABLE
(
	NUM INT
)
AS
BEGIN
	IF @N IS NULL
		INSERT INTO @TBL
			SELECT 1
	ELSE
	BEGIN
		INSERT INTO @TBL
			SELECT ID
			FROM dbo.Numbers WITH(NOLOCK)
			WHERE ID <= @N

	END

	RETURN
END
GO
