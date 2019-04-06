USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Subhost].[SUBHOST_LESSON_POSITION_EDIT]
	@LP_ID	INT,	
	@LP_NAME	VARCHAR(50),
	@LP_ORDER	SMALLINT,
	@ACTIVE	BIT
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Subhost.LessonPosition
	SET LP_NAME = @LP_NAME,
		LP_ORDER = @LP_ORDER,
		LP_ACTIVE = @ACTIVE
	WHERE LP_ID = @LP_ID
	
	UPDATE dbo.FieldTable
	SET FL_CAPTION = @LP_NAME
	WHERE FL_NAME = 'LP_NAME_' + CONVERT(VARCHAR(10), @LP_ID)

	UPDATE dbo.FieldTable
	SET FL_CAPTION = @LP_NAME + ' ����'
	WHERE FL_NAME = 'SLP_PRICE_' + CONVERT(VARCHAR(10), @LP_ID)

	UPDATE dbo.FieldTable
	SET FL_CAPTION = @LP_NAME + ' �����'
	WHERE FL_NAME = 'SLP_SUM_' + CONVERT(VARCHAR(10), @LP_ID)
END