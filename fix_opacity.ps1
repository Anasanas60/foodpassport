// Run this command to see all withOpacity instances:
// Select-String -Path lib\food_journal_screen.dart -Pattern 'withOpacity'

// Manual fixes needed:
// Replace: Colors.someColor.withOpacity(0.X)
// With: Colors.someColor.withAlpha((0.X * 255).round())

// Example conversions:
// withOpacity(0.1) -> withAlpha(25)
// withOpacity(0.2) -> withAlpha(51) 
// withOpacity(0.3) -> withAlpha(76)
// withOpacity(0.4) -> withAlpha(102)
// withOpacity(0.5) -> withAlpha(128)
// withOpacity(0.6) -> withAlpha(153)
// withOpacity(0.7) -> withAlpha(179)
// withOpacity(0.8) -> withAlpha(204)
// withOpacity(0.9) -> withAlpha(230)

// Quick fix command for common values:
(Get-Content "lib\food_journal_screen.dart") | 
ForEach-Object { 
     -replace 'withOpacity\(0\.1\)', 'withAlpha(25)' 
       -replace 'withOpacity\(0\.2\)', 'withAlpha(51)' 
       -replace 'withOpacity\(0\.3\)', 'withAlpha(76)' 
       -replace 'withOpacity\(0\.4\)', 'withAlpha(102)' 
       -replace 'withOpacity\(0\.5\)', 'withAlpha(128)' 
       -replace 'withOpacity\(0\.6\)', 'withAlpha(153)' 
       -replace 'withOpacity\(0\.7\)', 'withAlpha(179)' 
       -replace 'withOpacity\(0\.8\)', 'withAlpha(204)' 
       -replace 'withOpacity\(0\.9\)', 'withAlpha(230)' 
} | Set-Content "lib\food_journal_screen.dart"
