USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Common].[PERIOD_ACTIVE]
	@ID			UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE	Common.Period
	SET		ACTIVE		=	CASE ACTIVE WHEN 1 THEN 0 ELSE 1 END,
			LAST		=	GETDATE()
	WHERE	ID			=	@ID
END
