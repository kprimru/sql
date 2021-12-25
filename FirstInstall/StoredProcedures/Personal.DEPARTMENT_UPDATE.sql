﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Personal].[DEPARTMENT_UPDATE]
	@DP_ID UNIQUEIDENTIFIER,
	@DP_NAME VARCHAR(50),
	@DP_FULL VARCHAR(250),
	@DP_DATE SMALLDATETIME
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @DP_ID_MASTER UNIQUEIDENTIFIER

	SELECT @DP_ID_MASTER = DP_ID_MASTER
	FROM Personal.DepartmentDetail
	WHERE DP_ID = @DP_ID

	DECLARE @OLD	VARCHAR(MAX)
	DECLARE @NEW	VARCHAR(MAX)

	EXEC Common.PROTOCOL_VALUE_GET 'DEPARTMENT', @DP_ID_MASTER, @OLD OUTPUT


	UPDATE	Personal.DepartmentDetail
	SET		DP_NAME	=	@DP_NAME,
			DP_FULL	=	@DP_FULL,
			DP_DATE	=	@DP_DATE
	WHERE	DP_ID	=	@DP_ID

	UPDATE	Personal.Department
	SET		DPMS_LAST	=	GETDATE()
	WHERE	DPMS_ID	=
		(
			SELECT	DP_ID_MASTER
			FROM	Personal.DepartmentDetail
			WHERE	DP_ID	=	@DP_ID
		)

	EXEC Common.PROTOCOL_VALUE_GET 'DEPARTMENT', @DP_ID_MASTER, @NEW OUTPUT

	EXEC Common.PROTOCOL_INSERT 'DEPARTMENT', 'Редактирование', @DP_ID_MASTER, @OLD, @NEW

END

GO
GRANT EXECUTE ON [Personal].[DEPARTMENT_UPDATE] TO rl_department_u;
GO
