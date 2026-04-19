# LocalConnect Port Configuration

## Fixed Port Setup

The LocalConnect Flutter project is configured to run on a **fixed port for consistent access**.

### Web/Edge Development Server Port
- **Port**: 5555
- **URL**: http://localhost:5555
- **Usage**: Used for all web-based development and testing

### Configuration Details

#### Files Modified
- [run_local_connect.bat](run_local_connect.bat) - Updated all Flutter run commands with `--web-port=5555`

#### Launch Options
1. **Windows Desktop**: `flutter run -d windows` (no fixed port)
2. **Edge/Web**: `flutter run -d edge --web-port=5555` ✅ **Recommended - Fixed Port**
3. **Auto Device**: `flutter run --web-port=5555` (uses fixed port)

### Running the Project

#### Via Batch Script
```batch
run_local_connect.bat
# Select option 2 for Edge (web) - runs on fixed port 5555
```

#### Direct Command
```bash
cd D:\MyWorkers\local_connect
flutter run -d edge --web-port=5555
```

### Debug Information

When running on port 5555:
- Debug Service: `ws://127.0.0.1:57600/...`
- DevTools: `http://127.0.0.1:57600/.../devtools/?uri=...`
- Application Entry: `org-dartlang-app:/web_entrypoint.dart`

### Hot Reload Commands (While Running)
- `r` - Hot reload (reload code without losing state)
- `R` - Hot restart (full restart)
- `d` - Detach (leave app running, exit flutter run)
- `q` - Quit (stop application)
- `h` - List all commands

### Port Status
To verify port 5555 is in use:
```powershell
netstat -ano | findstr :5555
```

### Notes
- Port 5555 was chosen because port 8080 was occupied by Apache (httpd.exe)
- The fixed port configuration ensures consistent development URL: `http://localhost:5555`
- All web-based development and testing uses this single port
