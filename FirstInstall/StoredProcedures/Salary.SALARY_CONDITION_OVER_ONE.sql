USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Salary].[SALARY_CONDITION_OVER_ONE]
	@IDLIST	UNIQUEIDENTIFIER,
	@DATE	SMALLDATETIME,
	@RC		INT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @MASTERID UNIQUEIDENTIFIER

	SELECT @MASTERID = SC_ID_MASTER
	FROM Salary.SalaryConditionDetail
	WHERE SC_ID = @IDLIST

	DECLARE @OLD	VARCHAR(MAX)
	DECLARE @NEW	VARCHAR(MAX)

	EXEC Common.PROTOCOL_VALUE_GET 'SALARY_CONDITION', @MASTERID, @OLD OUTPUT


	UPDATE	Salary.SalaryConditionDetail
	SET		SC_END	=	@DATE,
			SC_REF	=	3
	WHERE	SC_ID	=	@IDLIST


	EXEC Common.PROTOCOL_VALUE_GET 'SALARY_CONDITION', NULL, @NEW OUTPUT

	EXEC Common.PROTOCOL_INSERT 'SALARY_CONDITION', '��������', @MASTERID, @OLD, @NEW

END

GO
