USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[EVENT_TYPE_SELECT]
	@FILTER	VARCHAR(100) = NULL,
	@HIDDEN	BIT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT EventTypeID, EventTypeName, EventTypeReport, EventTypeHide
	FROM dbo.EventTypeTable
	WHERE		
		(EventTypeReport = 1 OR @HIDDEN = 1)
		AND
			(
				IS_MEMBER('rl_event_type_hide') = 1 AND EventTypeHide = 0 OR IS_MEMBER('rl_event_type_hide') = 0
			)
		AND(
			 @FILTER IS NULL
			OR EventTypeName LIKE @FILTER
			)
	ORDER BY EventTypeName
END