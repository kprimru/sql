USE [BuhDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SYSTEM_TYPE_CHECK]
	@SYSTEM	VARCHAR(150),
	@DISTR	VARCHAR(150)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ENABLE BIT

	SET @ENABLE =
		(

	SELECT TOP 1 ENABLE
	FROM
		dbo.SystemDistrType
		INNER JOIN dbo.SystemTable ON ID_SYSTEM = SystemID
		INNER JOIN dbo.DistrTypeTable ON ID_TYPE = DistrTypeID
	WHERE SystemName = @SYSTEM AND DistrTypeName = @DISTR
	)

	SELECT ISNULL(@ENABLE, 1) AS ENABLE
END
GO
GRANT EXECUTE ON [dbo].[SYSTEM_TYPE_CHECK] TO DBCount;
GO
