USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Автор:
Дата создания:  
Описание:
*/

ALTER PROCEDURE [dbo].[USER_ROLES_SELECT]
	@username VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		DECLARE @user TABLE
			(
				UserName VARCHAR(100),
				GroupName VARCHAR(100),
				LoginName VARCHAR(100),
				DefDBName VARCHAR(100),
				DefSchemaName VARCHAR(100),
				UserID INT,
				SID VARBINARY(1000)
			)

		INSERT INTO @user
			EXEC sp_helpuser @username

		SELECT * FROM @user

		DECLARE @roles TABLE (
			DbRole VARCHAR(50),
			MemberName VARCHAR(50),
			MemberSID VARBINARY(256)
			)

		INSERT INTO @roles
			EXEC sp_helprolemember

		DECLARE @total TABLE (
			DbRole VARCHAR(50)
			)


		INSERT INTO @total
			SELECT GroupName
			FROM @user

		INSERT INTO @total
			SELECT DBRole
			FROM @roles a
			WHERE MemberName IN
				(
					SELECT GroupName
					FROM @user
				) AND NOT EXISTS
				(
					SELECT *
					FROM @total b
					WHERE a.DBRole = b.DBRole
				)

		WHILE EXISTS
				(
					SELECT *
					FROM @roles a
					WHERE EXISTS
						(
							SELECT *
							FROM @roles b
							WHERE a.MemberName = b.DBRole
						) AND NOT EXISTS
						(
							SELECT *
							FROM @total b
							WHERE a.DBRole = b.DBRole
						)
				)
		BEGIN
			INSERT INTO @total
				SELECT DBRole
				FROM @roles a
				WHERE MemberName IN
					(
						SELECT DBRole
						FROM @roles
					) AND NOT EXISTS
					(
						SELECT *
						FROM @total b
						WHERE a.DBRole = b.DBRole
					)
		END


		SELECT * from @total

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[USER_ROLES_SELECT] TO rl_all_r;
GO