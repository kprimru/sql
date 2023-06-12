USE [DocumentClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[Variables]
(
        [ID]          UniqueIdentifier      NOT NULL,
        [USER_NAME]   NVarChar(256)         NOT NULL,
        [VARIABLES]   xml                   NOT NULL,
        [LAST]        DateTime              NOT NULL,
        CONSTRAINT [PK_Common.Variables] PRIMARY KEY CLUSTERED ([ID])
);
GO
