USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [Ric].[GrowFactValue]
(
	@PR_ID	SMALLINT
)
RETURNS DECIMAL(10, 4)
AS
BEGIN
	DECLARE @RES DECIMAL(10, 4)

	DECLARE @VKSP_START	DECIMAL(10, 4)
	DECLARE @VKSP_END	DECIMAL(10, 4)

	SELECT	@VKSP_START = Ric.VKSPGet(dbo.PERIOD_DELTA(@PR_ID, -12), @PR_ID),
			@VKSP_END	= Ric.VKSPGet(@PR_ID, @PR_ID)

	SELECT	@RES = 100 * (@VKSP_END - @VKSP_START - 0/*?????? ��� ��� ??????*/) / @VKSP_START

	RETURN @RES
END
GO
